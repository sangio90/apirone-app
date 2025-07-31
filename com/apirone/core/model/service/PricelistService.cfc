component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="PricelistDAO";
	property name="cacheScope" type="String" default="Pricelist.bean";

	public com.apirone.core.model.bean.Pricelist function get( required String pricelistId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.pricelistId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.pricelistId );
		cm.put( getCacheScope(), arguments.pricelistId, bean );

		return bean;
	}

	private com.apirone.core.model.bean.Pricelist function build( required String pricelistId ){
		var record = getDao().read( arguments.pricelistId );

		if ( record.RecordCount ) {
			var obj = super.bean( "Pricelist" );
			obj.setId( record.pricelist_id.toString() );
			obj.setName( record.pricelist );
			return obj;
		}

		return NullValue();
	}

}
