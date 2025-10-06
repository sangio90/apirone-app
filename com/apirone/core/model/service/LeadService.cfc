component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="CrmApiService" inject="CrmApiService";
	property name="CrmMapper" inject="CrmMapper";
	property name="cacheScope" type="String" default="Lead.bean";

	/**
	 * Recupera cliente dalla cache, o dal CRM se necessario (senza DB)
	 */
	public com.apirone.core.model.bean.Lead function get( required String leadId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.leadId );

		if ( cache.status ) {
			return cache.data;
		}

		// Recupera da CRM e mappa
		var crmData  = getCrmApiService().getLead( leadId );
		var lead = new com.apirone.core.model.bean.Lead();
		if (!IsNull(crmData) && !isNull(crmData.data)) {
			crmData = crmData.data;
			lead = getCrmMapper().mapLead( crmData );
			cm.put( getCacheScope(), leadId, lead );
		}

		return lead;
	}

	/**
	 * Cerca clienti: recupera dal CRM e mappa
	 */
	public com.apirone.core.model.bean.Result function search( String str ){
		var result = super.getResult();
		var cm = getCacheManager();

		var crmResults = getCrmApiService().searchLeads( str );
		var leads  = [];

		for ( var crmData in crmResults.data ) {
			var cache = cm.get( getCacheScope(), crmData.id );
			if ( cache.status ) {
				leads.append( cache.data );
				continue;
			}
			var lead = getCrmMapper().mapLead( crmData );
			var cacheKey = lead.getId();

			getCacheManager().put( getCacheScope(), cacheKey, lead );
			leads.append( lead );
		}

		result.setData( leads );
		result.setTotal( leads.len() );
		result.setCount( leads.len() );

		return result;
	}

}
