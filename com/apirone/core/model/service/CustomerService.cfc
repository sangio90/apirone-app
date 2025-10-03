component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="CrmApiService" inject="CrmApiService";
	property name="CrmMapper" inject="CrmMapper";
	property name="cacheScope" type="String" default="Customer.bean";

	/**
	 * Recupera cliente dalla cache, o dal CRM se necessario (senza DB)
	 */
	public com.apirone.core.model.bean.Customer function get( required String customerId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.customerId );

		if ( cache.status ) {
			return cache.data;
		}

		// Recupera da CRM e mappa
		var crmData  = getCrmApiService().getCustomer( customerId );
		if (!IsNull(crmData)) {
			crmData = crmData.data;
		}
		var customer = getCrmMapper().mapCustomer( crmData );
		cm.put( getCacheScope(), customerId, customer );

		return customer;
	}

	/**
	 * Cerca clienti: recupera dal CRM e mappa
	 */
	public com.apirone.core.model.bean.Result function search( String str ){
		var result = super.getResult();
		var cm = getCacheManager();

		var crmResults = getCrmApiService().searchCustomers( str );
		var customers  = [];

		for ( var crmData in crmResults.data ) {
			var cache = cm.get( getCacheScope(), crmData.id );
			if ( cache.status ) {
				customers.append( cache.data );
				continue;
			}
			var customer = getCrmMapper().mapCustomer( crmData );
			var cacheKey = customer.getId();

			getCacheManager().put( getCacheScope(), cacheKey, customer );
			customers.append( customer );
		}

		result.setData( customers );
		result.setTotal( customers.len() );
		result.setCount( customers.len() );

		return result;
	}

}
