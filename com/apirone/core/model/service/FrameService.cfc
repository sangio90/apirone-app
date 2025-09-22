component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="FrameDAO";
	property name="statusService" inject="StatusService";
	property name="lookupService" inject="LookupService";
	property name="frameCellService" inject="FrameCellService";

	property name="cacheScope" type="String" default="Frame.bean";

	public com.apirone.core.model.bean.Frame function get( required String frameId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.frameId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.frameId );
		cm.put( getCacheScope(), arguments.frameId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public com.apirone.core.model.bean.Result function search(
		String str,
		String statusId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "frame.code", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( frameId = record.Frame_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.Frame frame ){

		var newId = getDao().insert( arguments.Frame );

		if( ( !IsNull( arguments.frame.getCells() ) ) ) {
			
			for( var cell in arguments.frame.getCells() ) {
				cell.setFrameId( newId );
				getFrameCellService().create( cell );
			}
		
		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.Frame frame ){

		transaction {

			getDao().update( arguments.frame );

			getFrameCellService().deleteByFrameId( arguments.frame.getId() );

			if( ( !IsNull( arguments.frame.getCells() ) ) ) {
				
				for( var cell in arguments.frame.getCells() ) {
					cell.setFrameId( frame.getId() );
					getFrameCellService().create( cell );
				}
			
			}

		}

		super.getCacheManager().remove( getCacheScope(), arguments.Frame.getId() );

		return arguments.Frame.getId();
	}

	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.frame_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}

	/**
	 * @auditEvent frame.deleted
	 * @auditMessage frame [@frameId@] deleted
	 * @auditPayload { "id": "@frameId@" }
	 */
	public com.apirone.core.model.bean.Outcome function delete( required String frameId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.frameId );

		outcome.setData( { frameId = arguments.frameId } );

		transaction {
			try {
				var result = getDao().delete( arguments.frameId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( getCacheScope(), arguments.frameId );

				// super.logAction( type = "frame.DELETED", message = "frame [#arguments.frameId#] deleted" );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.error.CannotDeleteFrame" );
				outcome.setMessage( "Cannot delete frame [#arguments.frameId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.Frame function build( required String frameId ){
		var record = getDao().read( arguments.frameId );

		if ( record.recordCount ) {
			var bean = super.bean( "frame" );

			bean.setId( record.Frame_id );
			bean.setName( record.frame );
			bean.setCode( record.code );
			bean.setCreatedAt( record.created_at );

			bean.setOrientation( getLookupservice().get( "orientation",  record.orientation_id ) );
			bean.setCellOrientation( getLookupservice().get( "orientation",  record.cell_orientation_id )  );
			bean.setStatus( getStatusService().get( record.status_id ) );

			bean.setCells( getFrameCellService().list( record.frame_id ) );

			return bean;
		}

		return NullValue();
	}

}
