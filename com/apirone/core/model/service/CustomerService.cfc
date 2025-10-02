component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="CrmApiService" inject="CrmApiService";
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
		var crmData  = getCrmService().getCustomer( customerId );
		var customer = getCrmMapper().mapCustomer( crmData );

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
		var crmResults = getCrmService().searchCustomers( searchTerm );
		var customers  = [];

		for ( var crmData in crmResults ) {
			var customer = getCrmMapper().mapCustomer( crmData );
			// Salva in cache per accesso futuro
			var cacheKey = "customer_#customer.getId()#"; // Assumi che crmData abbia id

			getCacheManager().put( cacheKey, customer, 3600 );

			customers.append( customer );
		}

		result.setData( customers );
		result.setTotal( customers.len() );
		result.setCount( customers.len() );

		return result;
	}

}
