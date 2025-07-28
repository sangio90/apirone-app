component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="SizeConfigDAO";
	property name="sizeService" inject="SizeService";
	property name="productCategoryService" inject="ProductCategoryService";
	property name="lineService" inject="LineService";
	property name="textService" inject="TextService";

	property name="cacheScope" type="String" default="SizeConfig.bean";

	public com.apirone.core.model.bean.SizeConfig function get( required String sizeConfigId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.sizeConfigId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.sizeConfigId );
		cm.put( getCacheScope(), arguments.sizeConfigId, bean );

		return bean;
	}

	public String function create( required com.apirone.core.model.bean.SizeConfig sizeConfig ){
		var newId = getDao().insert( arguments.sizeConfig );
		return newId;
	}

	public String function update( required com.apirone.core.model.bean.SizeConfig sizeConfig ){
		getDao().update( arguments.sizeConfig );

		var id = arguments.sizeConfig.getId();
		super.getCacheManager().remove( getCacheScope(), arguments.sizeConfig.getId() );
		return arguments.sizeConfig.getId();
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.SizeConfig function build( required String sizeConfigId ){
		var record = getDao().read( arguments.sizeConfigId );

		if ( record.recordCount ) {
			var bean = super.bean( "SizeConfig" );

			bean.setId( record.size_config_id );
			bean.setSize( getSizeService().get(record.size_id) );
			bean.setProductCategory( getProductCategoryService().get(record.product_category_id) );
			bean.setLine( getLineService().get(record.line_id) );
			bean.setHeight( record.height );
			bean.setWidth( record.width );
			return bean;
		}

		return NullValue();
	}


	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public com.apirone.core.model.bean.Result function search(
		String sizeId,
		Number productCategoryId,
		String lineId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ ]
		){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( sizeConfigId = record.size_config_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.recordcount ) );

		return result;
	}

}
