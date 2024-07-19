<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cfset companyId = "azapi">

	<cffunction name="read">

		<cfargument name="sizeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">

			SELECT *
			FROM
				sizes
			WHERE
				size_id = <cfqueryparam cfsqltype="varchar" value="#arguments.sizeId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

    
	<cffunction returntype="Query" name="find">

		<cfargument name="lineId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="orderby">

        <cfquery name="local.q" datasource="apirone">
			SELECT
				size_id,
				COUNT(size_id) OVER() AS total
			FROM
				sizes
			WHERE 1=1

				<cfif !IsNull( arguments.lineId )>
                    AND comcol.clcodart = <cfqueryparam value="#arguments.componentId#" cfsqltype="varchar">
                </cfif>
			
			ORDER BY 
				#super.sanitizeSQL( arguments.orderby )#
		</cfquery>

		<cfreturn local.q>

	</cffunction>	

</cfcomponent>