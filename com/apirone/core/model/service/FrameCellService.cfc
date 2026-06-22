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

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

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


	/**
	 * Recupera in batch più FrameCell dato un array di ID.
	 * Restituisce uno Struct chiave = frameCellId, valore = bean FrameCell.
	 * Precarica i lookup (frameCellType, orientation) con cache locale per evitare il problema N+1.
	 *
	 * @ids Array di frameCellId
	 * @return Struct mappato per frameCellId -> FrameCell
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Cache locali per i lookup (LookupService è in-memory, cache locale evita iterazioni ripetute)
		var types        = {};
		var orientations = {};

		for ( var record in records ) {
			var bean = super.bean( "FrameCell" );

			// Campi diretti dal record
			bean.setId( record.frame_cell_id );
			bean.setRow( record.row );
			bean.setCol( record.col );
			bean.setWidth( record.width );
			bean.setHeight( record.height );
			bean.setFrameId( record.frame_id );
			bean.setCreatedAt( record.created_at );

			// Lookup: frameCellType cached localmente
			if ( !StructKeyExists( types, record.type_id ) ) {
				types[ record.type_id ] = getLookupService().get( "frameCellType", record.type_id );
			}
			bean.setType( types[ record.type_id ] );

			// Lookup: orientation cached localmente
			if ( !StructKeyExists( orientations, record.orientation_id ) ) {
				orientations[ record.orientation_id ] = getLookupService().get( "orientation", record.orientation_id );
			}
			bean.setOrientation( orientations[ record.orientation_id ] );

			map[ record.frame_cell_id ] = bean;
		}

		return map;
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
