<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="lineModelCostId" type="Numeric" required="true">
		<cfquery name="local.q" datasource="apirone">
			SELECT
				line_model_cost_id,
				line_id::varchar,
				model_id::varchar,
				product_category_id,
				cost
			FROM
				line_model_costs
			WHERE
				line_model_cost_id = <cfqueryparam cfsqltype="Integer" value="#arguments.lineModelCostId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Recupera in batch più record dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query">
		<cfargument name="ids" type="Array" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				line_model_cost_id,
				line_id::varchar,
				model_id::varchar,
				product_category_id,
				cost
			FROM
				line_model_costs
			WHERE
				line_model_cost_id IN (<cfqueryparam value="#ArrayToList( arguments.ids )#" list="true" cfsqltype="integer">)
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="categoryId" type="Numeric">
		<cfargument name="lineId" type="String">
		<cfargument name="modelId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="20">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="line_model_cost_id">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				line_model_cost_id,
				COUNT(line_model_cost_id) OVER() AS total
			FROM
				line_model_costs
					INNER JOIN product_categories USING (product_category_id)
					INNER JOIN lines USING (line_id)
					INNER JOIN models USING (model_id)
			WHERE 1=1

			<cfif !IsNull( arguments.categoryId )>
				AND line_model_costs.product_category_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.categoryId#">
			</cfif>

			<cfif !IsNull( arguments.lineId ) AND Len( arguments.lineId )>
				AND line_model_costs.line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
			</cfif>

			<cfif !IsNull( arguments.modelId ) AND Len( arguments.modelId )>
				AND line_model_costs.model_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.modelId#">::uuid
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

	<!---
		Combinazioni categoria/linea/modello esistenti a catalogo (da catalog_bundles):
		alimentano le select a cascata della pagina di configurazione.
	--->
	<cffunction name="listCombinations" returntype="Query">
		<cfquery name="local.q" datasource="apirone">
			SELECT DISTINCT
				product_category_id,
				line_id::varchar,
				model_id::varchar
			FROM
				catalog_bundles
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String" output="false">
		<cfargument name="lineModelCost" type="com.apirone.core.model.bean.LineModelCost" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO line_model_costs (
				line_id,
				model_id,
				product_category_id,
				cost
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.lineModelCost.getLine().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.lineModelCost.getModel().getId()#">::uuid,
				<cfqueryparam cfsqltype="Integer" value="#arguments.lineModelCost.getCategory().getId()#">,
				<cfqueryparam cfsqltype="Numeric" scale="5" value="#arguments.lineModelCost.getCost()#">
			) RETURNING line_model_cost_id
		</cfquery>

		<cfreturn local.q.line_model_cost_id>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="lineModelCost" type="com.apirone.core.model.bean.LineModelCost" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				line_model_costs
			SET
				line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineModelCost.getLine().getId()#">::uuid,
				model_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineModelCost.getModel().getId()#">::uuid,
				product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.lineModelCost.getCategory().getId()#">,
				cost = <cfqueryparam cfsqltype="Numeric" scale="5" value="#arguments.lineModelCost.getCost()#">
			WHERE
				line_model_cost_id = <cfqueryparam cfsqltype="Integer" value="#arguments.lineModelCost.getId()#">
		</cfquery>

		<cfreturn arguments.lineModelCost.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="lineModelCostId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone" result="local.r">
			DELETE FROM
				line_model_costs
			WHERE
				line_model_cost_id = <cfqueryparam cfsqltype="Integer" value="#arguments.lineModelCostId#">
		</cfquery>

		<cfreturn local.r.recordCount>
	</cffunction>
</cfcomponent>
