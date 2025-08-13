<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="signageConfigId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				signage_configs
			WHERE
				signage_config_id = <cfqueryparam cfsqltype="Integer" value="#arguments.signageConfigId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="categoryId" type="Numeric">
		<cfargument name="modelId" type="String">
		<cfargument name="lineId" type="String">
		<cfargument name="catalogBundleId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="20">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="signage_config_id">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				signage_config_id,
				COUNT(signage_config_id) OVER() AS total
			FROM
				signage_configs
					INNER JOIN catalog_bundles USING (catalog_bundle_id)
			WHERE 1=1

				<cfif !IsNull( arguments.catalogBundleId )>
					AND signage_configs.catalog_bundle_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.catalogBundleId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.categoryId )>
					AND catalog_bundles.product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.categoryId#">
				</cfif>

				<cfif !IsNull( arguments.modelId )>
					AND catalog_bundles.model_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.modelId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.lineId )>
					AND catalog_bundles.line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
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

	<cffunction name="insert" returntype="Numeric" output="false">
		<cfargument name="line" type="com.apirone.core.model.bean.SignageConfig" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO signage_configs (
				catalog_bundle_id,
				font_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.line.getCatalogBundle().getId()#">::uuid,
				<cfqueryparam cfsqltype="Integer" value="#arguments.line.getFont().getId()#">
			) RETURNING signage_config_id
		</cfquery>

		<cfreturn local.q.signage_config_id>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="signageConfigId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				signage_configs
			WHERE
				signage_config_id = <cfqueryparam cfsqltype="Integer" value="#arguments.signageConfigId#">
			RETURNING signage_config_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>
</cfcomponent>

