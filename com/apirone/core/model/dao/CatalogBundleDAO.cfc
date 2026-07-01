<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="catalogBundleId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT line_id::varchar, model_id::varchar, catalog_bundle_id::varchar, *
			FROM
				catalog_bundles
			WHERE
				catalog_bundle_id = <cfqueryparam cfsqltype="varchar" value="#arguments.catalogBundleId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String">
		<cfargument name="statusId" type="Numeric">
		<cfargument name="lineId" type="String">
		<cfargument name="modelId" type="String">
		<cfargument name="categoryId" type="Numeric">

		<cfargument name="limit" required="true" type="Numeric" default="20">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="created_at desc">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				catalog_bundle_id::varchar,
				COUNT(catalog_bundle_id) OVER() AS total
			FROM
				catalog_bundles
			WHERE 1=1

				<cfif !IsNull( arguments.categoryId )>
					AND catalog_bundles.product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.categoryId#">
				</cfif>

				<cfif !IsNull( arguments.modelId )>
					AND catalog_bundles.model_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.modelId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.lineId )>
					AND catalog_bundles.line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.statusId )>
					AND catalog_bundles.status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.statusId#">
				</cfif>

				<cfif !IsNull( arguments.str )>
					AND
					(
						catalog_bundles.catalog_bundle ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
						OR
						catalog_bundles.catalog_bundle_id::varchar ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
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
		<cfargument name="catalogBundle" type="com.apirone.core.model.bean.CatalogBundle" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO catalog_bundles (
				line_id,
				model_id,
				product_category_id
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.catalogBundle.getLine().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.catalogBundle.getModel().getId()#">::uuid,
				<cfqueryparam cfsqltype="Integer" value="#arguments.catalogBundle.getCategory().getId()#">
			) RETURNING catalog_bundle_id
		</cfquery>

		<cfreturn local.q.catalog_bundle_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="catalogBundle" type="com.apirone.core.model.bean.CatalogBundle" required="true">

		<cfset var id = arguments.catalogBundle.getId()>

		<!--- linea/modello/categoria vengono aggiornati solo se presenti sul bean:
			il salvataggio massivo dei markup dalla griglia passa solo id + markupValue --->
		<cfquery name="local.q" datasource="apirone">
			UPDATE
				catalog_bundles
			SET
				<cfif !IsNull( arguments.catalogBundle.getLine() )>
					line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.catalogBundle.getLine().getId()#">::uuid,
				</cfif>
				<cfif !IsNull( arguments.catalogBundle.getModel() )>
					model_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.catalogBundle.getModel().getId()#">::uuid,
				</cfif>
				<cfif !IsNull( arguments.catalogBundle.getCategory() )>
					product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.catalogBundle.getCategory().getId()#">,
				</cfif>
				markup_value = <cfqueryparam cfsqltype="Numeric" value="#arguments.catalogBundle.getMarkupValue()#">
			WHERE
				catalog_bundle_id = <cfqueryparam cfsqltype="Varchar" value="#id#">::uuid
		</cfquery>

		<cfreturn id>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="catalogBundleId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				catalog_bundles
			WHERE
				catalog_bundle_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.catalogBundleId#">::uuid
			RETURNING catalog_bundle_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

	<!---
		Recupera in batch più catalog bundle dato un array di ID.
	--->
	<cffunction name="readByIds" returntype="Query" access="public">
		<cfargument name="ids" type="Array" required="true">

		<cfset var idsList = ArrayToList(arguments.ids)>

		<cfquery name="local.q" datasource="apirone">
			SELECT line_id::varchar, model_id::varchar, catalog_bundle_id::varchar, *
			FROM catalog_bundles
			WHERE catalog_bundle_id = ANY(
				<cfqueryparam value="#idsList#" list="false" cfsqltype="varchar">::uuid[]
			)
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>
