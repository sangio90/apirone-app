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

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( record.linemodel_id ) );
		} );

		return rows;
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
			obj.setProductCategory( getProductCategoryService().get( record.product_category_id ) );

			return obj;
		}

		return NullValue();
	}

}
