<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="lineCostId" type="Numeric" required="true">
		<cfquery name="local.q" datasource="apirone">
			SELECT
				*
			FROM
				line_costs
			WHERE
				line_cost_id = <cfqueryparam cfsqltype="Integer" value="#arguments.lineCostId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="categoryId" type="Numeric">
		<cfargument name="lineId" type="String">
		<cfargument name="finishId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="20">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="line_cost_id">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				line_cost_id,
				COUNT(line_cost_id) OVER() AS total
			FROM
				line_costs
					INNER JOIN product_categories USING (product_category_id)
					INNER JOIN lines USING (line_id)
					INNER JOIN finishes USING (finish_id)
			WHERE 1=1

			<cfif !IsNull( arguments.categoryId )>
				AND line_costs.product_category_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.categoryId#">
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
			INSERT INTO line_costs (
				line_id,
				finish_id,
				product_category_id,
				cost
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.line_cost.getLine().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.line_cost.getFinish().getId()#">::uuid,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.line_cost.getCategory().getId()#">,
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
				line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.line_cost.getLine().getId()#">::uuid,
				finish_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.line_cost.getFinish().getId()#">::uuid,
				product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.line_cost.getCategory().getId()#">,
				cost = <cfqueryparam cfsqltype="Numeric" value="#arguments.line_cost.getCost()#">
			WHERE
				line_cost_id = <cfqueryparam cfsqltype="Integer" value="#arguments.line_cost.getId()#">
		</cfquery>

		<cfreturn arguments.line_cost.getId()>
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

