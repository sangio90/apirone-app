component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="catalogBundleService" inject="catalogBundleService";
	property name="signageConfigService" inject="signageConfigService";

	property name="cacheScope" type="String" default="CatalogBundleSignageConfig.bean";

	public com.apirone.core.model.bean.SignageConfig function get( required String catalogBundleId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.catalogBundleId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.catalogBundleId );
		cm.put(
			getCacheScope(),
			arguments.catalogBundleId,
			bean
		);

		return bean;
	}

	/*
    	private method
	*/

	private com.apirone.core.model.bean.CatalogBundleSignageConfig function build(
		required String catalogBundleId
	){
		var record = getDao().read( arguments.catalogBundleId );

		if ( record.recordCount ) {
			var bean = super.bean( "CatalogBundleSignageConfig" );

			bean.setId( catalogBundleId );
			bean.setCreatedAt( Now() );

			bean.setCatalogBundle( getCatalogBundleService().get( catalogBundleId = catalogBundleId ) );
			bean.setConfigs( getSignageConfigService().list( catalogBundleId = catalogBundleId ) );

			return bean;
		}

		return NullValue();
	}

}
