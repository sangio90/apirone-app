<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	
	<cffunction name="read">

		<cfargument name="vatCodeId" type="String" required="true">

		<cfquery name="local.q" datasource="verticale">
			SELECT
				*
			FROM 
				codpag
			WHERE 
				pagcod = <cfqueryparam cfsqltype="varchar" value="#arguments.paymentTypeId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="find">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="verticale">
			SELECT 
                pagcod,
				COUNT(pagcod) OVER() AS total
			FROM 
                codpag
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