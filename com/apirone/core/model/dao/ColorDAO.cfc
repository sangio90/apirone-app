<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cfset companyId = "azapi">

	<cffunction name="read">

		<cfargument name="colorId" type="String" required="true">

		<cfquery name="local.q" datasource="verticale">

			SELECT *
			FROM
				#variables.companyId#_colori
			WHERE
				clcodice = <cfqueryparam cfsqltype="varchar" value="#arguments.colorId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>
	
	<!---
		cvrcom
		listin
	--->
	
	<cffunction returntype="Query" name="find">

		<cfargument name="componentId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="colori.clcodice">

        <cfquery name="local.q" datasource="verticale">
			SELECT
				clcodice,
				COUNT(clcodice) OVER() AS total
			FROM
				#super.sanitizeSQL( "#variables.companyId#_colori" )# colori

                <cfif !IsNull( arguments.componentId )>
                    INNER JOIN #super.sanitizeSQL( "#variables.companyId#_comcol" )# comcol ON comcol.clcodcol = colori.clcodice
                </cfif>

			WHERE 1=1

				<cfif !IsNull( arguments.componentId )>
                    AND comcol.clcodart = <cfqueryparam value="#arguments.componentId#" cfsqltype="varchar">
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