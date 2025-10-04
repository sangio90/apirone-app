<cfcomponent accessors="true">
    
	<cfproperty name="CacheManager" type="com.apirone.core.util.CacheManager">

	<cffunction name="getCosts" returntype="Query">
		
		<cfset var result = "">

		<cfset var cm = getCacheManager()>

		<cfset var cache = cm.get( scope = "verticale.query", key = "costs"  )>

		<cfif cache.status>

			<cfreturn cache.data>

		</cfif>

		<cfquery name="local.q" datasource="verticale">
			SELECT *
			FROM 
				azapi_listin AS listin
			ORDER BY 1
		</cfquery>

		<cffile action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# read 'azapi_listin' table from Verticale">

		<cfset cm.put( scope="verticale.query",  key = "costs" , value = local.q )>

		<cfreturn  local.q>

	</cffunction>

</cfcomponent>
