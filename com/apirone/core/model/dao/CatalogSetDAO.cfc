<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="catalogSetId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT line_id::varchar, model_id::varchar, catalog_set_id::varchar, *
			FROM
				catalog_sets
			WHERE
				catalog_set_id = <cfqueryparam cfsqltype="varchar" value="#arguments.catalogSetId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String">
		<cfargument name="statusId" type="Numeric">
		<cfargument name="lineId" type="String">
		<cfargument name="modelId" type="String">
		<cfargument name="categoryId" type="Numeric">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="code">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				catalog_set_id::varchar,
				COUNT(catalog_set_id) OVER() AS total
			FROM
				catalog_sets
			WHERE 1=1

				<cfif !IsNull( arguments.categoryId )>
					AND catalog_sets.product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.categoryId#">
				</cfif>

				<cfif !IsNull( arguments.modelId )>
					AND catalog_sets.model_id = <cfqueryparam cfsqltype="Integer" value="#arguments.modelId#">
				</cfif>

				<cfif !IsNull( arguments.lineId )>
					AND catalog_sets.line_id = <cfqueryparam cfsqltype="Integer" value="#arguments.lineId#">
				</cfif>

				<cfif !IsNull( arguments.statusId )>
					AND catalog_sets.status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.statusId#">
				</cfif>

				<cfif !IsNull( arguments.str )>
					AND
					(
						catalog_sets.line_model ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
					)
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
		<cfargument name="catalogSet" type="com.apirone.core.model.bean.Line" required="true">

		<cfset var categories = super.getCategoriesAsArray( line.getCategories() )>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO catalog_sets (
				line_id,
				model_id,
				product_category_id
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.catalogSet.getLine().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.catalogSet.getModel().getId()#">::uuid,
				<cfqueryparam cfsqltype="Integer" value="#arguments.catalogSet.getCategory().getId()#">
			) RETURNING catalog_set_id
		</cfquery>

		<cfreturn local.q.catalog_set_id.toString()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="catalogSetId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				catalog_sets
			WHERE
				catalog_set_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.catalogSetId#">::uuid
			RETURNING catalog_set_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>
</cfcomponent>
