component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="CatalogSetDAO";
	property name="lineService" inject="LineService";
	property name="modelService" inject="ModelService";
	property name="productCategoryService" inject="ProductCategoryService";

	property name="CacheScope" type="String" default="CatalogSet.bean";

	public com.apirone.core.model.bean.CatalogSet function get( required String catalogSetId ){
		var cm = super.getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.catalogSetId );

		if ( cache.catalogSet ) {
			return cache.data;
		}

		var obj = build( arguments.catalogSetId );

		cm.put( getCacheScope(), catalogSetId, obj );

		return obj;
	}

	public Array function list(){
		var rows = [];

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		String categoryId,
		String modelId,
		String lineId,
		String statusId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "line.code", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( record.catalog_set_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.CatalogSet function getOrCreate(
		required String lineId,
		required String modelId,
		required String categoryId
	){
		var record = getDao().find(
			lineId     = arguments.lineId,
			modelId    = arguments.modelId,
			categoryId = arguments.categoryId
		);

		if ( !record.recordCount ) {
			var bean = super.bean( "CatalogSet" );

			bean.setLine( getLineService().get( arguments.lineId ) );
			bean.setModel( getModelService().get( arguments.modelId ) );
			bean.setCategory( getProductCategoryService().get( arguments.categoryId ) );

			var newId = create( bean );

			return get( newId );
		}

		return get( record.catalog_set_id );
	}


	public Array function exists(
		required String lineId,
		required String modelId,
		required String categoryId
	){
		var records = getDao().find( argumentCollection = arguments );

		if ( records.recordcount ) {
			return true;
		}

		return false;
	}

	/*
    	private method
	*/

	private com.apirone.core.model.bean.CatalogSet function build( required String catalogSetId ){
		var record = getDao().read( arguments.catalogSetId );

		if ( record.RecordCount ) {
			var obj = super.bean( "CatalogSet" );

			obj.setId( record.catalog_set_id );
			obj.setName( record.line_model );
			obj.setLine( getLineService().get( record.line_id ) );
			obj.setModel( getModelService().get( record.model_id ) );
			obj.setCategory( getProductCategoryService().get( record.product_category_id ) );

			return obj;
		}

		return NullValue();
	}

}
