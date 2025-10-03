<cfcomponent extends="com.opusplus.core.model.dao.AbsDAO" accessors="true">
    
	<cfproperty name="CacheManager" inject="CacheManager">

	<cffunction name="getCosts" returntype="Query">
		
		<cfset var result = "">

		<cfset var cm = getCacheManager()>
	
		<cfset var cache = cm.get( scope = "verticale.query", key = "costs"  )>

		<cfif cache.status>

			<cfreturn cache.data>

		</cfif>

		<cfquery name="local.q" datasource="verticale">
			SELECT 
				lisart + '*' AS lisart_, 
				liscvr + '*' AS liscvr_, 
				liscol + '*' AS liscol_, 
				lispre + '*' AS lispre
			FROM 
				azapi_listin
			ORDER BY 
				lisart, liscvr, liscol
		</cfquery>

		<cfset cm.put( scope="cfquery.verticale",  key = "costs" , value = local.q )>

		<cfreturn  local.q>

	</cffunction>

</cfcomponent>
