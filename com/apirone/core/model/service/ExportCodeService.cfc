component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ExportCodeDAO";

	public com.apirone.core.model.bean.ExportCode function get( required Numeric exportCodeId ){
		return build( arguments.exportCodeId );
	}

	/**
	 * Mappa hash della voce di preventivo -> codice export, per le stampe.
	 * Gli hash senza codice non compaiono nella mappa: chi stampa decide cosa
	 * fare (di norma non scrive nulla).
	 */
	public Struct function mapByHashes( required Array hashes ){
		var map = {};

		if ( !ArrayLen( arguments.hashes ) ) {
			return map;
		}

		var records = getDao().findByHashes( arguments.hashes );

		for ( var record in records ) {
			map[ record.hash ] = record.export_code;
		}

		return map;
	}

	public Numeric function max(
		String exportCode
	){
		return getDao().max( argumentCollection = arguments );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		Numeric productHashId,
		required Numeric limit    = 15,
		required Numeric offset   = 0,
		required Array orderBy    = [ { field = "exportCode.id" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Il find() ora restituisce tutte le colonne: si possono costruire i bean direttamente
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( buildFromFindRow( record ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric exportCodeId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.exportCodeId );

		outcome.setData( { exportCodeId = arguments.exportCodeId } );

		transaction {
			try {
				getDao().delete( arguments.exportCodeId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteExportCode" );
				outcome.setMessage( "Cannot delete Export Code [#arguments.exportCodeId#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.ExportCode exportCode ){
		return getDao().insert( arguments.exportCode );
	}

	public String function update( required com.apirone.core.model.bean.ExportCode exportCode ){
		getDao().update( arguments.exportCode );

		return arguments.exportCode.getId();
	}

	/**
	 * Costruisce un bean ExportCode a partire dall'ID. Delega a buildFromFindRow() dopo la lettura del record.
	 */
	private com.apirone.core.model.bean.ExportCode function build( required Numeric exportCodeId ){
		var record = getDao().read( arguments.exportCodeId );

		if ( record.recordCount ) {
			return buildFromFindRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean ExportCode a partire da una riga della query, senza chiamata DB aggiuntiva.
	 */
	private com.apirone.core.model.bean.ExportCode function buildFromFindRow( required any record ){
		var bean = super.bean( "ExportCode" );

		// Campi diretti dal record (ExportCode non ha sub-entity)
		bean.setId( record.export_code_id );
		bean.setName( record.export_code );
		bean.setCounter( record.counter );
		bean.setProductHashId( record.product_hash_id );

		return bean;
	}

}
