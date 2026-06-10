component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="SearchDAO";
	property name="productService" inject="ProductService";

	public com.apirone.core.model.bean.SearchTerm function get( required String searchTermId ){
		return build( arguments.searchTermId );
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "line.code", desc = "asc" } ]
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

	/*
    	private method
	*/

	/**
	 * Costruisce un bean SearchTerm a partire dall'ID. Delega a buildFromFindRow() dopo la lettura del record.
	 */
	private com.apirone.core.model.bean.SearchTerm function build( required String searchTermId ){
		var record = getDao().read( arguments.searchTermId );

		if ( record.recordCount ) {
			return buildFromFindRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean SearchTerm a partire da una riga della query.
	 * La sub-entity Product è caricata con chiamata individuale.
	 */
	private com.apirone.core.model.bean.SearchTerm function buildFromFindRow( required any record ){
		var bean = super.bean( "SearchTerm" );

		// Campi diretti dal record
		bean.setId( record.search_term_id );
		bean.setTerm( record.search_term );
		bean.setCreatedAt( record.created_at );

		// Entity collegata (Product è caricato singolarmente)
		bean.setProduct( getProductService().get( record.product_id ) );

		return bean;
	}

}
