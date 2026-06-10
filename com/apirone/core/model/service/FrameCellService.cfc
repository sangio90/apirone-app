component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="FrameCellDAO";
	property name="lookupService" inject="LookupService";

	public com.apirone.core.model.bean.FrameCell function get( required String frameCellId ){
		return build( arguments.frameCellId );
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

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( r ){
			ids.append( r.frame_cell_id );
		} );

		var beanMap = {};
		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );

			allRecords.each( function( r ){
				beanMap[ r.frame_cell_id ] = buildFromRow( r );
			} );
		}

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.frame_cell_id ] );
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

		outcome.setData( { frameId = arguments.frameId } );

		transaction {
			try {
				var result = getDao().deleteByFrameId( frameId = arguments.frameId );
				outcome.setData( { "deletedCount" = result } )
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.error.CannotDeleteFrameCells" );
				outcome.setMessage( "Cannot delete cells by frameId [#arguments.frameId#]" );
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
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean FrameCell a partire da una riga della query.
	 * Utilizzato sia da build() (record singolo) che da search() (iterazione batch).
	 */
	private com.apirone.core.model.bean.FrameCell function buildFromRow( required any row ){
		var bean = super.bean( "FrameCell" );

		// Campi diretti dal record
		bean.setId( arguments.row.frame_cell_id );
		bean.setRow( arguments.row.row );
		bean.setCol( arguments.row.col );
		bean.setWidth( arguments.row.width );
		bean.setHeight( arguments.row.height );
		bean.setFrameId( arguments.row.frame_id );
		bean.setCreatedAt( arguments.row.created_at );

		// Entity collegate (lookup leggeri)
		bean.setType( getLookupService().get( "frameCellType", arguments.row.type_id ) );
		bean.setOrientation( getLookupService().get( "orientation", arguments.row.orientation_id ) );

		return bean;
	}

}
