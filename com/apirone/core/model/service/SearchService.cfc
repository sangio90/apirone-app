component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="SearchDAO";
	property name="productService" inject="ProductService";

	property name="cacheScope" type="String" default="SearchTerm.bean";

	public com.apirone.core.model.bean.SearchTerm function get( required String searchTermId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.searchTermId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.searchTermId );
		cm.put( getCacheScope(), arguments.searchTermId, bean );

		return bean;
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

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( searchTermId = record.search_term_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/*
    	private method
	*/

	private com.apirone.core.model.bean.SearchTerm function build( required String searchTermId ){
		var record = getDao().read( arguments.searchTermId );

		if ( record.recordCount ) {
			var bean = super.bean( "SearchTerm" );

			bean.setId( record.search_term_id );
			bean.setTerm( record.search_term );
			bean.setCreatedAt( record.created_at );
			bean.setProduct( getProductService().get( record.product_id ) );

			return bean;
		}

		return NullValue();
	}

}
