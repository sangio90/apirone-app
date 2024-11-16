<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cfset companyId = "azapi">

	<cffunction name="read">

		<cfargument name="sizeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT size_id::varchar, *
			FROM
				sizes
			WHERE
				size_id = <cfqueryparam cfsqltype="varchar" value="#arguments.sizeId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

    
	<cffunction returntype="Query" name="find">

		<cfargument name="lineId" type="String">
		
		<cfargument name="orderby" required="true" type="String" default="orderby">

        <cfquery name="local.q" datasource="apirone">
			SELECT DISTINCT
				size_id::varchar, 
				orderby,
				COUNT(size_id) OVER() AS total
			FROM
				sizes
					<cfif !IsNull( arguments.lineId )>
						INNER JOIN combinations USING ( size_id )
					</cfif>
			WHERE 1=1
				
				<cfif !IsNull( arguments.lineId )>
                    AND combinations.line_id = <cfqueryparam value="#arguments.lineId#" cfsqltype="varchar">::uuid
                </cfif>
			
			ORDER BY 
				#super.sanitizeSQL( arguments.orderby )#
		</cfquery>

		<cfreturn local.q>

	</cffunction>	

</cfcomponent>