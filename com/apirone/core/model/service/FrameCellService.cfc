component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="FrameCellDAO";

	property name="cacheScope" type="String" default="FrameCell.bean";

	public com.apirone.core.model.bean.FrameCell function get( required String frameCellId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.frameCellId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.frameCellId );
		cm.put( getCacheScope(), arguments.frameCellId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public com.apirone.core.model.bean.Result function search(
		String frameId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "frameCell.id", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( frameCellId = record.frame_cell_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.FrameCell frameCell ){
		var newId = getDao().insert( arguments.frameCell );
		return newId;
	}

	public com.apirone.core.model.bean.Outcome function deleteByFrameId(
		required String frameId,
	){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.frameId );

		outcome.setData( { frameCellId = arguments.frameId } );

		transaction {
			try {
				var result = getDao().deleteByFrameId( frameId = arguments.frameId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( getCacheScope(), arguments.frameId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.error.CannotDeleteFRameCell" );
				outcome.setMessage( "Cannot delete frame cells by frameId [#arguments.frameId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.FrameCell function build( required String frameCellId ){
		var record = getDao().read( arguments.frameCellId );

		if ( record.recordCount ) {
			var bean = super.bean( "FrameCell" );

			bean.setId( record.frame_cell_id );
			bean.setRow( record.row );
			bean.setCol( record.col );
			bean.setValue( record.value );
			bean.setFrameId( record.frame_id );
			bean.setCreatedAt( record.created_at );

			return bean;
		}

		return NullValue();
	}

}
