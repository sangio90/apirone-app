component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="CurrencyDAO";
	property name="cacheScope" type="String" default="Currency.bean";

	public com.apirone.core.model.bean.Currency function get( required String currencyId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.currencyId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.currencyId );
		cm.put( getCacheScope(), arguments.currencyId, bean );

		return bean;
	}

	private com.apirone.core.model.bean.Currency function build( required String currencyId ){
		var record = getDao().read( arguments.currencyId );

		if ( record.RecordCount ) {
			var obj = super.bean( "Currency" );
			obj.setId( record.currency_id.toString() );
			obj.setName( record.name );
			return obj;
		}

		return NullValue();
	}
}
