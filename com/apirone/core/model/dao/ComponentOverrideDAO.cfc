<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="ComponentOverrideId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				component_overrides
			WHERE
				component_override_id = <cfqueryparam cfsqltype="Integer" value="#arguments.ComponentOverrideId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="productId" type="String">
		<cfargument name="productItemId" type="Numeric">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="created_at desc">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				component_override_id,
				COUNT(component_override_id) OVER() AS total
			FROM
				component_overrides
			WHERE 1=1

				<cfif !IsNull( arguments.productItemId )>
					AND product_item_id = <cfqueryparam value="#arguments.productItemId#" cfsqltype="Integer">
				</cfif>

				<cfif !IsNull( arguments.componentId )>
					AND component_id = <cfqueryparam value="#arguments.componentId#" cfsqltype="Integer">
				</cfif>

			ORDER BY
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GTE 0>
				LIMIT
					<cfqueryparam cfsqltype="integer" value="#arguments.limit#">
				OFFSET
					<cfqueryparam cfsqltype="integer" value="#arguments.offset#">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<!--- <cfargument name="component" type="com.apirone.core.model.bean.Component" required="true"> --->
		<cfargument name="ComponentOverrideId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone" result="result">
			DELETE FROM
				component_overrides
			WHERE
				component_override_id  <cfqueryparam cfsqltype="Integer" value="#arguments.ComponentOverrideId#">
		</cfquery>

		<cfreturn true>
	</cffunction>

	<cffunction name="insert" returntype="Numeric">
		<cfargument name="componentOverride" type="com.apirone.core.model.bean.ComponentOverride" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO component_overrides (
				component_id,
				product_item_id,
				quantity,
				deleted
			)
			VALUES (
				<cfqueryparam cfsqltype="Numeric" value="#arguments.componentOverride.getComponentId()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.componentOverride.getProductItemId()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.componentOverride.getQuantity()#">,
				<cfqueryparam cfsqltype="Boolean" value="#arguments.componentOverride.getDeleted()#">
			) RETURNING component_override_id
		</cfquery>

		<cfreturn local.q.component_override_id>
	</cffunction>

	<cffunction name="update" returntype="Numeric">
		<cfargument name="ComponentOverride" type="com.apirone.core.model.bean.ComponentOverride" required="true">

		<cfquery name="local.q" datasource="apirone" result="result">
			UPDATE
				component_overrides
			SET
				quantity = <cfqueryparam cfsqltype="Numeric" value="#arguments.ComponentOverride.getQuantity()#">,
				deleted = <cfqueryparam cfsqltype="Boolean" value="#arguments.ComponentOverride.getDeleted()#">
			WHERE
				component_override_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.ComponentOverride.getId()#">
		</cfquery>

		<cfreturn arguments.ComponentOverride.getId()>
	</cffunction>
</cfcomponent>
