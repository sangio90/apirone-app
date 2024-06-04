<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	
	<cffunction name="read">

		<cfargument name="vatCodeId" type="String" required="true">

		<cfquery name="local.q" datasource="verticale">
			SELECT
				*
			FROM 
				codiva
			WHERE 
				ivacod = <cfqueryparam cfsqltype="varchar" value="#arguments.vatCodeId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="find">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="verticale">
			SELECT 
				ivacod,
				COUNT(ivacod) OVER() AS total
			FROM 
				codiva
			WHERE 1=1
			<cfif arguments.limit GTE 0>
				LIMIT 
					<cfqueryparam cfsqltype="integer" value="#arguments.limit#">
				OFFSET
					<cfqueryparam cfsqltype="integer" value="#arguments.offset#">
			</cfif>
		</cfquery>

		<cfreturn local.q>

	</cffunction>

</cfcomponent>