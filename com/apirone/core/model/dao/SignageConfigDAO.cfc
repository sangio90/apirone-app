<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="signageConfigId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				signage_configs
			WHERE
				signage_config_id = <cfqueryparam cfsqltype="Integer" value="#arguments.signageConfigId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String">
		<cfargument name="categoryId" type="Numeric">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="code">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				signage_config_id,
				COUNT(signage_config_id) OVER() AS total
			FROM
				signage_configs
			WHERE 1=1

				<cfif !IsNull( arguments.catalogSetId )>
					AND signage_configs.catalog_set_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.catalogSetId#">
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
		<cfargument name="line" type="com.apirone.core.model.bean.Line" required="true">

		<cfset var categories = super.getCategoriesAsArray( line.getCategories() )>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO signage_configs (
				catalog_set_id,
				font_id
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.line.getCatalogSet().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.line.getFont().getId()#">
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

