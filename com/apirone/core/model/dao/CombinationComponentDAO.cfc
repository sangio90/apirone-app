<cfcomponent extends="com.apirone.core.model.dao.VerticaleDAO" accessors="true">

	<cffunction name="read">

		<cfargument name="combinationComponentId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="verticale">
			SELECT *
			FROM
                combination_item_components
			WHERE
                combination_item_component_id = <cfqueryparam cfsqltype="Integer" value="#arguments.combinationComponentId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	
	<cffunction returntype="Query" name="find">

		<cfargument name="combinationItemId" type="Numeric">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="created_at desc">

        <cfquery name="local.q" datasource="verticale">
			SELECT
                combination_item_component_id,
				COUNT(combination_item_component_id) OVER() AS total
			FROM
            combination_item_components
			WHERE 1=1
			
			<cfif !isNull( arguments.combinationItemId )>
				AND combination_item_id = <cfqueryparam value="#arguments.typeId#" cfsqltype="Integer">
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