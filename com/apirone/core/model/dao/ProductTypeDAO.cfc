<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<!--- TODO: put in configuration --->
	<cfset variables.companyId = "azapi">

	<cffunction returntype="Query" name="read">

		<cfargument name="typeId" type="String" required="true">

		<cfquery name="local.q" datasource="verticale">
			SELECT *
			FROM #variables.companyId#_codtip
			WHERE codtip = <cfqueryparam cfsqltype="varchar" value="#arguments.typeId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction returntype="Query" name="find">

		<cfargument name="str" type="String">    	

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="destip">

        <cfquery name="local.q" datasource="verticale">
			SELECT
				codtip,
				COUNT(codtip) OVER() AS total
			FROM
				<cfqueryparam value="#variables.companyId()#_codtip" cfsqltype="Varchar">
			WHERE 1=1
                
				<cfif Len( trim( arguments.str ) )>
					AND destip ILIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="Varchar">
				</cfif>

			ORDER BY 
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GT 0>
				LIMIT  
					<cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET 
					<cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>

		<cfreturn local.q>

	</cffunction>

</cfcomponent>