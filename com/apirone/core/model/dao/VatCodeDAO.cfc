<cfcomponent extends="com.apirone.core.model.dao.VerticaleDAO" accessors="true">
	
	<cffunction name="read">

		<cfargument name="vatCodeId" type="String" required="true">

		<cfif !request.loadFromVerticale>
			<cfreturn super.getMockedVatCode( arguments.vatCodeId )>
		</cfif>		

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

		<cfif !request.loadFromVerticale>
			<cfreturn super.listMockedVatCode()>
		</cfif>				

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