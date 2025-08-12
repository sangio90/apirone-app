component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="LineModelDAO";
	property name="lineService" inject="LineService";
	property name="modelService" inject="ModelService";
	property name="productCategoryService" inject="ProductCategoryService";

	property name="CacheScope" type="String" default="LineModel.bean";

	public com.apirone.core.model.bean.LineModel function get( required String lineModelId ){
		var cm = super.getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.lineModelId );

		if ( cache.lineModel ) {
			return cache.data;
		}

		var obj = build( arguments.lineModelId );

		cm.put( getCacheScope(), lineModelId, obj );

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
			rows.add( get( record.linemodel_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public Array function exists(
		required String lineId,
		required String modelId,
		required String categoryId
	){

		var records = getDao().find( argumentCollection = arguments );

		if( records.recordcount ) {

			return true;

		}

		return false;
	}

	/*
    	private method
	*/

	private com.apirone.core.model.bean.LineModel function build( required String lineModelId ){
		var record = getDao().read( arguments.lineModelId );

		if ( record.RecordCount ) {
			var obj = super.bean( "LineModel" );

			obj.setId( record.linemodel_id );
			obj.setName( record.linemodel );
			obj.setLine( getLineService().get( record.line_id ) );
			obj.setModel( getModelService().get( record.model_id ) );
			obj.setCategory( getProductCategoryService().get( record.product_category_id ) );

			return obj;
		}

		return NullValue();
	}

}
