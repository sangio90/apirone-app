<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<!---
		Legge dalla tabella locale sincronizzata dal CRM (crm_opportunities), non
		più dal vivo via CrmApiService. La forma del ritorno resta identica a
		quella che CrmApiService.getOpportunity()/searchOpportunities()
		restituivano, così OpportunityService/CrmMapper non cambiano.
	--->

	<cffunction name="get" access="public" returntype="Struct">
		<cfargument name="opportunityId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT data
			FROM crm_opportunities
			WHERE id = <cfqueryparam cfsqltype="varchar" value="#arguments.opportunityId#">
		</cfquery>

		<cfif local.q.recordCount EQ 0>
			<cfreturn {}>
		</cfif>

		<cfreturn { "data" = DeserializeJSON( local.q.data[ 1 ] ) }>
	</cffunction>

	<cffunction name="find" access="public" returntype="Struct">
		<cfargument name="str" type="String" required="false" default="">
		<cfargument name="limit" type="Numeric" required="false" default="10">
		<cfargument name="offset" type="Numeric" required="false" default="0">

		<cfquery name="local.q" datasource="apirone">
			SELECT data, COUNT(*) OVER() AS total
			FROM crm_opportunities
			WHERE deleted = false
				<cfif Len( Trim( arguments.str ) )>
					AND name ILIKE <cfqueryparam cfsqltype="varchar" value="%#Trim( arguments.str )#%">
				</cfif>
			ORDER BY name
			LIMIT <cfqueryparam cfsqltype="integer" value="#arguments.limit#">
			OFFSET <cfqueryparam cfsqltype="integer" value="#arguments.offset#">
		</cfquery>

		<cfset var rows = []>
		<cfloop query="local.q">
			<cfset ArrayAppend( rows, DeserializeJSON( local.q.data ) )>
		</cfloop>

		<cfreturn {
			"total" = local.q.recordCount ? local.q.total[ 1 ] : 0,
			"count" = local.q.recordCount,
			"data"  = rows
		}>
	</cffunction>

</cfcomponent>
