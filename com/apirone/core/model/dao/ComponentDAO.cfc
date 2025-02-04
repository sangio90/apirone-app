<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read">

		<cfargument name="componentId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
                components
			WHERE
				component_id = <cfqueryparam cfsqltype="Integer" value="#arguments.componentId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	
	<cffunction returntype="Query" name="find">

		<cfargument name="combinationItemId" type="Numeric">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="created_at desc">

        <cfquery name="local.q" datasource="apirone">
			SELECT
                component_id,
				COUNT(component_id) OVER() AS total
			FROM
            	components
			WHERE 1=1
			
			<cfif !isNull( arguments.combinationItemId )>
				AND combination_item_id = <cfqueryparam value="#arguments.combinationItemId#" cfsqltype="Integer">
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

    
	<cffunction name="delete" returntype="Boolean">

		<cfargument name="componentId" type="Numeric" required="true">
		<cfargument name="combinationComponent" type="com.apirone.core.model.bean.CombinationComponent" required="true">

        <cfquery name="local.q" datasource="apirone">
			DELETE FROM components
			WHERE
				combination_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.componentId#">
				AND product_it = <cfqueryparam cfsqltype="Varchar" value="#arguments.combinationComponent.getComponent().getId()#">
				AND variant_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.combinationComponent.getVariant().getId()#">
				AND color_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.combinationComponent.getColor().getId()#">
		</cfquery>

		<cfreturn true>

	</cffunction>

	<cffunction name="insert" returntype="Numeric">

		<cfargument name="componentId" type="Numeric" required="true">
		<cfargument name="combinationComponent" type="com.apirone.core.model.bean.CombinationComponent" required="true">

        <cfquery name="local.q" datasource="apirone">
			INSERT INTO components (
				combination_item_id,
				product_it,
				color_id,
				variant_id,
				quantity
			)
			VALUES (
				<cfqueryparam cfsqltype="Numeric" value="#arguments.componentId#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.combinationComponent.getComponent().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.combinationComponent.getColor().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.combinationComponent.getVariant().getId()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.combinationComponent.getQuantity()#">
			) RETURNING component_id
		</cfquery>

		<cfreturn local.q.component_id>

	</cffunction>

</cfcomponent>