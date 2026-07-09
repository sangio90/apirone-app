<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="modelConfigId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT model_config_id::varchar, *
			FROM
				model_configs
			WHERE
				model_config_id = <cfqueryparam cfsqltype="varchar" value="#arguments.modelConfigId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String" output="false">
		<cfargument name="modelConfig" type="com.apirone.core.model.bean.ModelConfig" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO model_configs
			(
				model_id,
				product_category_id,
				line_id,
				width,
				height,
				length
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.modelConfig.getModel().getId()#">::uuid,
				<cfqueryparam cfsqltype="Integer" value="#arguments.modelConfig.getProductCategory().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.modelConfig.getLine().getId()#">::uuid,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.modelConfig.getWidth()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.modelConfig.getHeight()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.modelConfig.getLength()#" null="#IsNull( arguments.modelConfig.getLength() )#">
			) RETURNING model_config_id
		</cfquery>

		<cfreturn local.q.model_config_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="modelConfig" type="com.apirone.core.model.bean.ModelConfig" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				model_configs
			SET
				model_id = <cfqueryparam cfsqltype="varchar" value="#arguments.modelConfig.getModel().getId()#">::uuid,
				product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.modelConfig.getProductCategory().getId()#">,
				line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.modelConfig.getLine().getId()#">::uuid,
				width = <cfqueryparam cfsqltype="Numeric" value="#arguments.modelConfig.getWidth()#">,
				height = <cfqueryparam cfsqltype="Numeric" value="#arguments.modelConfig.getHeight()#">,
				length = <cfqueryparam cfsqltype="Numeric" value="#arguments.modelConfig.getLength()#" null="#IsNull( arguments.modelConfig.getLength() )#">
			WHERE
				model_config_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.modelConfig.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.modelConfig.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="modelConfigId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				model_configs
			WHERE
				model_config_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.modelConfigId#">::uuid
			RETURNING model_config_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

	<!---
		Recupera in batch più ModelConfig dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query" access="public">
		<cfargument name="ids" type="Array" required="true">

		<cfreturn super.$readByIdsUuid(
			table   = "model_configs",
			pkColumn = "model_config_id",
			ids     = arguments.ids
		)>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="modelId" type="String">
		<cfargument name="productCategoryId" type="String">
		<cfargument name="lineId" type="String">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				model_config_id::varchar,
				model_id::varchar,
				product_category_id,
				line_id::varchar,
				COUNT(model_config_id) OVER() AS total
			FROM
				model_configs
			WHERE
			1=1
			<cfif !IsNull( arguments.modelId )>
				AND model_configs.model_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.modelId#">::uuid
			</cfif>
			<cfif !IsNull( arguments.productCategoryId )>
				AND model_configs.product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productCategoryId#">
			</cfif>
			<cfif !IsNull( arguments.lineId )>
				AND model_configs.line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>

