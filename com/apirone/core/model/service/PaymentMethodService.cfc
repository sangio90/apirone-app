component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="PaymentMethodDAO";
	property name="cacheScope" type="String" default="PaymentMethod.bean";

	public com.apirone.core.model.bean.PaymentMethod function get( required String paymentMethodId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.paymentMethodId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.paymentMethodId );
		cm.put(
			getCacheScope(),
			arguments.paymentMethodId,
			bean
		);

		return bean;
	}

	private com.apirone.core.model.bean.PaymentMethod function build( required String paymentMethodId ){
		var record = getDao().read( arguments.paymentMethodId );

		if ( record.RecordCount ) {
			var obj = super.bean( "PaymentMethod" );

			obj.setId( record.payment_method_id.toString() );
			obj.setName( record.payment_method );

			return obj;
		}

		return NullValue();
	}

}
