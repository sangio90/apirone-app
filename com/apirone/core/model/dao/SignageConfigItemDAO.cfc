<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="signageConfigItemId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				signage_config_items
			WHERE
				signage_config_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.signageConfigItemId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String">
		<cfargument name="signageConfigId" type="Numeric">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="code">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				signage_config_item_id,
				COUNT(signage_config_item_id) OVER() AS total
			FROM
				signage_config_items
			WHERE 1=1

				<cfif !IsNull( arguments.signageConfigId )>
					AND signage_config_items.signage_config_id = <cfqueryparam cfsqltype="Integer" value="#arguments.signageConfigId#">
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
		<cfargument name="signageConfigItem" type="com.apirone.core.model.bean.SignageConfigItem" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO signage_config_items (
				signage_config_id,
				height,
				height_in_pixel,
				row_count,
				char_count,
				font_family_size_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Integer" value="#arguments.signageConfigItem.getSignageConfigId()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.signageConfigItem.getHeight()#" scale="2">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.signageConfigItem.getHeightInPixel()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.signageConfigItem.getRowCount()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.signageConfigItem.getCharCount()#">,
				<cfif !IsNull( arguments.signageConfigItem.getSize() )>
					<cfqueryparam cfsqltype="Integer" value="#arguments.signageConfigItem.getSize().getId()#">
				<cfelse>
					NULL
				</cfif>
			) RETURNING signage_config_item_id
		</cfquery>

		<cfreturn local.q.signage_config_item_id>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="signageConfigItemId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				signage_config_items
			WHERE
				signage_config_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.signageConfigItemId#">
			RETURNING signage_config_item_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>
</cfcomponent>
