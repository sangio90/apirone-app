component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="CatalogBundleDAO";
	property name="lineService" inject="LineService";
	property name="modelService" inject="ModelService";
	property name="productCategoryService" inject="ProductCategoryService";

	property name="CacheScope" type="String" default="CatalogBundle.bean";

	public com.apirone.core.model.bean.CatalogBundle function get( required String catalogBundleId ){
		var cm = super.getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.catalogBundleId );

		if ( cache.status ) {
			return cache.data;
		}

		var obj = build( arguments.catalogBundleId );

		cm.put( getCacheScope(), catalogBundleId, obj );

		return obj;
	}

	public Array function list(){
		var rows = [];

		return search( argumentCollection = arguments ).getData();
	}

	public String function findId(
		required String modelId,
		required Numeric categoryId,
		required String lineId
	){
		var record = getDao().find( argumentCollection = arguments );

		return Len( record.catalog_bundle_id ) ? record.catalog_bundle_id : NullValue();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		String categoryId,
		String modelId,
		String lineId,
		String statusId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "catalogBundle.createdAt", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( record.catalog_bundle_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.CatalogBundle function getOrCreate(
		required com.apirone.core.model.bean.CatalogBundle catalogBundle
	){
		var record = getDao().find(
			lineId     = arguments.catalogBundle.getLine().getId(),
			modelId    = arguments.catalogBundle.getModel().getId(),
			categoryId = arguments.catalogBundle.getCategory().getId()
		);

		if ( !record.recordCount ) {
			var bean = super.bean( "CatalogBundle" );

			var newId = create( arguments.catalogBundle );

			return get( newId );
		}

		return get( record.catalog_bundle_id );
	}

	public String function create( required com.apirone.core.model.bean.CatalogBundle catalogBundle ){
		var newId = getDao().insert( arguments.catalogBundle );

		return newId;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.CatalogBundle function build( required String catalogBundleId ){
		var record = getDao().read( arguments.catalogBundleId );

		if ( record.RecordCount ) {
			var obj = super.bean( "CatalogBundle" );

			obj.setId( record.catalog_bundle_id );
			obj.setName( record.catalog_bundle );
			obj.setCreatedAt( record.created_at );

			obj.setLine( getLineService().get( record.line_id ) );
			obj.setModel( getModelService().get( record.model_id ) );
			obj.setCategory( getProductCategoryService().get( record.product_category_id ) );

			return obj;
		}

		return NullValue();
	}

}
