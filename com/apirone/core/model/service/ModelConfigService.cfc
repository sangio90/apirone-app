component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ModelConfigDAO";
	property name="modelService" inject="ModelService";
	property name="productCategoryService" inject="ProductCategoryService";
	property name="lineService" inject="LineService";
	property name="textService" inject="TextService";

	property name="cacheScope" type="String" default="ModelConfig.bean";

	public com.apirone.core.model.bean.ModelConfig function get( required String modelConfigId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.modelConfigId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.modelConfigId );
		cm.put( getCacheScope(), arguments.modelConfigId, bean );

		return bean;
	}

	public String function create( required com.apirone.core.model.bean.ModelConfig modelConfig ){
		var newId = getDao().insert( arguments.modelConfig );
		return newId;
	}

	public String function update( required com.apirone.core.model.bean.ModelConfig modelConfig ){
		getDao().update( arguments.modelConfig );

		var id = arguments.modelConfig.getId();
		super.getCacheManager().remove( getCacheScope(), arguments.modelConfig.getId() );
		return arguments.modelConfig.getId();
	}


	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public com.apirone.core.model.bean.Result function search(
		String modelId,
		Number productCategoryId,
		String lineId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = []
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( modelConfigId = record.model_config_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.recordcount ) );

		return result;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.ModelConfig function build( required String modelConfigId ){
		var record = getDao().read( arguments.modelConfigId );

		if ( record.recordCount ) {
			var bean = super.bean( "ModelConfig" );

			bean.setId( record.model_config_id );
			bean.setModel( getModelService().get( record.model_id ) );
			bean.setProductCategory( getProductCategoryService().get( record.product_category_id ) );
			bean.setLine( getLineService().get( record.line_id ) );
			bean.setHeight( record.height );
			bean.setWidth( record.width );
			return bean;
		}

		return NullValue();
	}

}
