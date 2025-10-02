component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="crmService" inject="CrmService";
	property name="crmMapper" inject="CrmMapper";

	/**
	 * Recupera cliente dalla cache, o dal CRM se necessario (senza DB)
	 */
	public com.apirone.core.model.bean.Customer function get( required string customerId ){
		var cacheKey = "customer_#customerId#";
		var cached   = getCacheManager().get( cacheKey );

		if ( cached.status ) {
			return cached.data;
		}

		// Recupera da CRM e mappa
		var crmData  = crmService.getCustomer( customerId );
		var customer = crmMapper.mapCustomer( crmData );

		// Salva in cache (es. 1 ora)
		getCacheManager().put( cacheKey, customer, 3600 );

		return customer;
	}

	/**
	 * Cerca clienti: recupera dal CRM e mappa
	 */
	public com.apirone.core.model.Result function search( string searchTerm = "" ){
		var result = super.getResult();

		// Recupera risultati dal CRM
		var crmResults = crmService.searchCustomers( searchTerm );
		var customers  = [];

		for ( var crmData in crmResults ) {
			var customer = crmMapper.mapCrmCustomerToBean( crmData );
			// Salva in cache per accesso futuro
			var cacheKey = "crm_customer_#customer.getId()#"; // Assumi che crmData abbia id
			getCacheManager().put( cacheKey, customer, 3600 );
			customers.append( customer );
		}

		result.setData( customers );
		result.setTotal( customers.len() );
		result.setCount( customers.len() );

		return result;
	}

}
