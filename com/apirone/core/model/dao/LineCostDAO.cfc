<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfquery name="local.q" datasource="apirone">
			SELECT
				line_cost_id,
				line_costs.product_category_id as product_category_id,
				line_costs.line_id::varchar as line_id,
				line_costs.finish_id::varchar as finish_id,
				"cost"
			FROM
				line_costs
			LEFT JOIN
				lines ON lines.line_id = line_costs.line_id
			LEFT JOIN
				finishes ON finishes.finish_id = line_costs.finish_id
			LEFT JOIN
				product_categories ON product_categories.product_category_id = line_costs.product_category_id
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="lineId" type="String">
		<cfargument name="finishId" type="String">
		<cfargument name="productCategoryId" type="Numeric">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="code">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				line_costs.line_cost_id,
				COUNT(line_costs.line_cost_id) OVER() AS total
			FROM
				line_costs
			LEFT JOIN
				lines ON lines.line_id = line_costs.line_id
			LEFT JOIN
				finishes ON finishes.finish_id = line_costs.finish_id
			LEFT JOIN
				product_categories ON product_categories.product_category_id = line_costs.product_category_id
			WHERE 1=1

			<cfif !IsNull( arguments.productCategoryId )>
				AND line_costs.product_category_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.productCategoryId#">
			</cfif>

			<cfif !IsNull( arguments.lineId )>
				AND line_costs.line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
			</cfif>

			<cfif !IsNull( arguments.finishId )>
				AND line_costs.finish_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.finishId#">::uuid
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

	<cffunction name="insert" returntype="String" output="false">
		<cfargument name="line_cost" type="com.apirone.core.model.bean.LineCost" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO lines (
				line_id,
				finish_id,
				product_category_id,
				cost
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.line_cost.getLine().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.line_cost.getFinish().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.line_cost.getProductCategory().getId()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.line_cost.getCost()#">
			) RETURNING line_cost_id
		</cfquery>

		<cfreturn local.q.line_cost_id>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="line_cost" type="com.apirone.core.model.bean.LineCost" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				line_costs
			SET
				line_id = <cfqueryparam cfsqltype="varchar" value="#arguments.line_cost.getLine().getId()#">::uuid,
				finish_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.line_cost.getFinish().getId()#">::uuid,
				product_category_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.line_cost.getProductCategory().getId()#">,
				cost = <cfqueryparam cfsqltype="Numeric" value="#arguments.line_cost.getCost()#">
			WHERE
				line_cost_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.line_cost.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.line.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="line_cost_id" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				line_costs
			WHERE
				line_cost_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.line_cost_id#">
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>
</cfcomponent>

