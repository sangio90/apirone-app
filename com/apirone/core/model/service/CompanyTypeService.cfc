component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="CompanyTypeDAO";

	public com.apirone.core.model.bean.CompanyType function get( required String companyTypeId ){
		return build( arguments.companyTypeId );
	}

	public com.apirone.core.model.bean.Result function search(
		required Numeric limit  = 50,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "category.name" } ],
		String str
	){
		var rows = [];

		var result = super.getResult()

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		for ( var record in records ) {
			ids.append( record.company_type_id );
		}

		var beanMap = {};
		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );

			allRecords.each( function( r ){
				beanMap[ r.company_type_id ] = buildFromRow( r );
			} );
		}

		// Ricostruisce le righe nell'ordine del find() originale
		for ( var record in records ) {
			rows.add( beanMap[ record.company_type_id ] );
		}

		result.setTotal( records.total );
		result.setCount( Val( records.recordcount ) );
		result.setData( rows );

		return result;
	}

	public com.apirone.core.model.bean.Result function list(
		required Array orderBy = [ { field = "category.name" } ],
		String str
	){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments );
	}

	/**
	 * Costruisce un bean CompanyType a partire dall'ID. Delega a buildFromRow() dopo la lettura del record.
	 */
	private com.apirone.core.model.bean.CompanyType function build( required String companyTypeId ){
		var record = getDao().read( arguments.companyTypeId );

		if ( record.RecordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean CompanyType a partire da una riga del query.
	 */
	private com.apirone.core.model.bean.CompanyType function buildFromRow( required any record ){
		var obj = super.bean( "CompanyType" );

		// Campi diretti dal record (CompanyType non ha sub-entity)
		obj.setId( arguments.record.company_type_id );
		obj.setName( arguments.record.company_type );

		return obj;
	}

}
