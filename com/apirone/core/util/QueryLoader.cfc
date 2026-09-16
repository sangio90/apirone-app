<cfcomponent accessors="true">
    
	<cfproperty name="CacheManager" type="com.apirone.core.util.CacheManager">

	<cffunction name="getCosts" returntype="Query">
		
		<cfset var cm = getCacheManager()>

		<cfset var cache = cm.get( scope = "verticale.query", key = "costs"  )>

		<cfif cache.status>

			<cfreturn cache.data>

		</cfif>

		<!---
			TODO: add "codice listino"?
				whats the field?
		---->

		<cfquery name="local.q" datasource="apirone">
			SELECT lisart, liscvr, liscol, lispre
			FROM
				verticale_price_list AS listin
			ORDER BY 1
		</cfquery>

		<cffile action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# read 'verticale_price_list' local table (synced from Verticale)">

		<cfset cm.put( scope="verticale.query",  key = "costs" , value = local.q )>

		<cfreturn  local.q>

	</cffunction>

</cfcomponent>
