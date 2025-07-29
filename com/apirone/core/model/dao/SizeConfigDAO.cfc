<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="sizeConfigId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT size_config_id::varchar, *
			FROM
				size_configs
			WHERE
				size_config_id = <cfqueryparam cfsqltype="varchar" value="#arguments.sizeConfigId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String" output="false">
		<cfargument name="sizeConfig" type="com.apirone.core.model.bean.SizeConfig" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO size_configs
			(
				size_id,
				product_category_id,
				line_id,
				width,
				height
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.sizeConfig.getSize().getId()#">::uuid,
				<cfqueryparam cfsqltype="Integer" value="#arguments.sizeConfig.getProductCategory().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.sizeConfig.getLine().getId()#">::uuid,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.sizeConfig.getWidth()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.sizeConfig.getHeight()#">

			) RETURNING size_config_id
		</cfquery>

		<cfreturn local.q.size_config_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="sizeConfig" type="com.apirone.core.model.bean.SizeConfig" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				size_configs
			SET
				size_id = <cfqueryparam cfsqltype="varchar" value="#arguments.sizeConfig.getSize().getId()#">::uuid,
				product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.sizeConfig.getProductCategory().getId()#">,
				line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.sizeConfig.getLine().getId()#">::uuid,
				width = <cfqueryparam cfsqltype="Numeric" value="#arguments.sizeConfig.getWidth()#">,
				height = <cfqueryparam cfsqltype="Numeric" value="#arguments.sizeConfig.getHeight()#">
			WHERE
				size_config_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.sizeConfig.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.sizeConfig.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="sizeConfigId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				size_configs
			WHERE
				size_config_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.sizeConfigId#">::uuid
			RETURNING size_config_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="sizeId" type="String">
		<cfargument name="productCategoryId" type="String">
		<cfargument name="lineId" type="String">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				size_config_id::varchar,
				size_id::varchar,
				product_category_id,
				line_id::varchar
			FROM
				size_configs
			WHERE
			1=1
			<cfif !IsNull( arguments.sizeId )>
				AND size_configs.size_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.sizeId#">::uuid
			</cfif>
			<cfif !IsNull( arguments.productCategoryId )>
				AND size_configs.product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productCategoryId#">
			</cfif>
			<cfif !IsNull( arguments.lineId )>
				AND size_configs.line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>

