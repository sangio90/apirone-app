<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cfset companyId = "azapi">

	<cffunction name="read">

		<cfargument name="variatId" type="String" required="true">

		<cfquery name="local.q" datasource="verticale">

			SELECT *
			FROM
                #super.sanitizeSQL( "#variables.companyId#_codvar" )#
			WHERE
				varcod = <cfqueryparam cfsqltype="varchar" value="#arguments.variatId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>
	
	<cffunction returntype="Query" name="find">

		<cfargument name="componentId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="codvar.varcod">
		
        <cfquery name="local.q" datasource="verticale">
			SELECT
				varcod,
				COUNT(varcod) OVER() AS total
			FROM
				#super.sanitizeSQL( "#variables.companyId#_codvar" )# AS codvar
                
                <cfif !IsNull( arguments.componentId )>
                    INNER JOIN #super.sanitizeSQL( "#variables.companyId#_comvar" )# AS comvar ON comvar.cbcodvar = codvar.varcod
                </cfif>
			WHERE 1=1
                
                <cfif !IsNull( arguments.componentId )>
                    AND cbcodart = <cfqueryparam value="#arguments.componentId#" cfsqltype="varchar">
                </cfif>
		
			ORDER BY 
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GT 0>
				OFFSET <cfqueryparam value="#arguments.offset#" cfsqltype="integer"> ROWS
				FETCH NEXT <cfqueryparam value="#arguments.limit#" cfsqltype="integer"> ROWS ONLY;
			</cfif>
		</cfquery>

		<cfreturn local.q>

	</cffunction>	

</cfcomponent>