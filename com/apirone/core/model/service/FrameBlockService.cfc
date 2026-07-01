component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="FrameBlockDAO";

	public com.apirone.core.model.bean.FrameBlock function get( required String frameBlockId ){
		return build( arguments.frameBlockId );
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

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( record ){
			ids.append( record.frame_block_id );
		} );

		// Costruisce tutti i bean in batch
		var beanMap = {};
		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );
			for ( var r in allRecords ) {
				beanMap[ r.frame_block_id ] = buildFromRow( r );
			}
		}

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.frame_block_id ] );
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
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean FrameBlock a partire da una riga del query.
	 */
	private com.apirone.core.model.bean.FrameBlock function buildFromRow( required any record ){
		var bean = super.bean( "FrameBlock" );

		bean.setId( arguments.record.frame_block_id );

		bean.setOrder( arguments.record.order );
		bean.setSlotCount( arguments.record.slot_count );

		if ( !IsNull( arguments.record.margin_top_mm ) ) bean.setMarginTopMm( arguments.record.margin_top_mm );
		if ( !IsNull( arguments.record.margin_left_mm ) ) bean.setMarginLeftMm( arguments.record.margin_left_mm );

		bean.setOrientationMode( arguments.record.orientation_mode );
		if ( !IsNull( arguments.record.rotatable ) ) bean.setRotatable( arguments.record.rotatable );

		bean.setFrameId( arguments.record.frame_id );
		bean.setCreatedAt( arguments.record.created_at );

		return bean;
	}

}
