component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="CrmOpportunityDAO";
	property name="CrmMapper" inject="CrmMapper";
	property name="cacheScope" type="String" default="Opportunity.bean";

	/**
	 * Recupera cliente dalla cache, o dal CRM se necessario (senza DB)
	 */
	public com.apirone.core.model.bean.Opportunity function get( required String opportunityId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.opportunityId );

		if ( cache.status ) {
			return cache.data;
		}

		// Recupera dalla tabella locale sincronizzata dal CRM e mappa
		var crmData  = getDao().get( opportunityId );
		var opportunity = super.bean("Opportunity");

		if ( StructKeyExists( crmData, "data" ) && !isNull(crmData.data)) {
			
			crmData = crmData.data;
			opportunity = getCrmMapper().mapOpportunity( crmData );
			
			cm.put( getCacheScope(), opportunityId, opportunity );
		}

		return opportunity;
	}

	/**
	 * Cerca clienti: recupera dal CRM e mappa
	 */
	public com.apirone.core.model.bean.Result function search( String str ){
		var result = super.getResult();
		var cm = getCacheManager();

		var crmResults = getDao().find( str );
		var opportunities  = [];

		for ( var crmData in crmResults.data ) {
			var cache = cm.get( getCacheScope(), crmData.id );
			if ( cache.status ) {
				opportunities.append( cache.data );
				continue;
			}
			var opportunity = getCrmMapper().mapOpportunity( crmData );
			var cacheKey = opportunity.getId();

			getCacheManager().put( getCacheScope(), cacheKey, opportunity );
			opportunities.append( opportunity );
		}

		result.setData( opportunities );
		result.setTotal( opportunities.len() );
		result.setCount( opportunities.len() );

		return result;
	}

}
