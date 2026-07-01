component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="FrameBlockDAO";

	property name="cacheScope" type="String" default="FrameBlock.bean";

	public com.apirone.core.model.bean.FrameBlock function get( required String frameBlockId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.frameBlockId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.frameBlockId );
		cm.put( getCacheScope(), arguments.frameBlockId, bean );

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
		required Array orderBy  = [ { field = "frameBlock.order", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( frameBlockId = record.frame_block_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.FrameBlock frameBlock ){
		var newId = getDao().insert( arguments.frameBlock );
		return newId;
	}

	public com.apirone.core.model.bean.Outcome function deleteByFrameId(
		required String frameId,
	){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { frameId = arguments.frameId } );

		transaction {
			try {
				var result = getDao().deleteByFrameId( frameId = arguments.frameId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( getCacheScope(), arguments.frameId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.error.CannotDeleteFrameBlocks" );
				outcome.setMessage( "Cannot delete blocks by frameId [#arguments.frameId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.FrameBlock function build( required Numeric frameBlockId ){
		var record = getDao().read( arguments.frameBlockId );

		if ( record.recordCount ) {
			var bean = super.bean( "FrameBlock" );

			bean.setId( record.frame_block_id );

			bean.setOrder( record.order );
			bean.setSlotCount( record.slot_count );

			if ( !IsNull( record.margin_top_mm ) ) bean.setMarginTopMm( record.margin_top_mm );
			if ( !IsNull( record.margin_left_mm ) ) bean.setMarginLeftMm( record.margin_left_mm );

			bean.setOrientationMode( record.orientation_mode );
			if ( !IsNull( record.rotatable ) ) bean.setRotatable( record.rotatable );

			bean.setFrameId( record.frame_id );
			bean.setCreatedAt( record.created_at );

			return bean;
		}

		return NullValue();
	}

}
