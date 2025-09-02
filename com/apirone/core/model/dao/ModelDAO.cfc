<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="modelId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT model_id::varchar, *
			FROM
				models
			WHERE
				model_id = <cfqueryparam cfsqltype="varchar" value="#arguments.modelId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="readByCode" output="false">
		<cfargument name="code" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				model_id::varchar,
				categories::varchar,
				*
			FROM
				models
			WHERE
				code = <cfqueryparam cfsqltype="varchar" value="#arguments.code#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction returntype="Query" name="find">
		<cfargument name="str" type="String">
		<cfargument name="categoryId" type="Numeric">
		<cfargument name="catalogBundleLineId" type="String">
		<cfargument name="lineId" type="String">
		<cfargument name="typeId" type="String">
		<cfargument name="statusId" type="String">

		<cfargument name="orderby" required="true" type="String" default="models.code">
		<cfargument name="limit" required="true" type="Numeric" default="15">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone">
			SELECT DISTINCT
				model_id::varchar,
				models.code,
				orderby,
				COUNT(model_id) OVER() AS total
			FROM
				models
					<cfif !IsNull( arguments.lineId )>
						-- TODO passare da catalog_bundles
						INNER JOIN products USING ( model_id )
					</cfif>
					<cfif !IsNull( arguments.catalogBundleLineId )>
						INNER JOIN catalog_bundles USING (model_id)
					</cfif>

			WHERE 1=1

				<cfif !IsNull( arguments.lineId )>
					AND products.line_id = <cfqueryparam value="#arguments.lineId#" cfsqltype="varchar">::uuid
				</cfif>

				<cfif !IsNull( arguments.typeId )>
					AND models.model_type_id = <cfqueryparam value="#arguments.typeId#" cfsqltype="varchar">
				</cfif>

				<cfif !IsNull( arguments.statusId )>
					AND models.status_id = <cfqueryparam value="#arguments.statusId#" cfsqltype="varchar">
				</cfif>

				<cfif !IsNull( arguments.catalogBundleLineId )>
					AND catalog_bundles.line_id = <cfqueryparam cfsqltype="varchar" value="#arguments.catalogBundleLineId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.str )>
					AND models.code ILIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="varchar">
				</cfif>

				<cfif !IsNull( arguments.categoryId )>
					AND categories @> ANY ('{[#arguments.categoryId#]}')
				</cfif>

			ORDER BY
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GTE 0>
				LIMIT
					<cfqueryparam cfsqltype="integer" value="#arguments.limit#">
				OFFSET
					<cfqueryparam cfsqltype="integer" value="#arguments.offset#">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String" output="false">
		<cfargument name="model" type="com.apirone.core.model.bean.Model" required="true">

		<cfset var categories = super.getCategoriesAsArray( model.getCategories() )>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO models (
				code,
				model,
				status_id,
				model_type_id,
				categories,
				fruits_count
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.model.getCode()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.model.getName()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.model.getStatus().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.model.getType().getId()#">,
				<cfqueryparam cfsqltype="Other" value="#SerializeJSON( categories )#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.model.getFruitsCount()#">
			) RETURNING model_id
		</cfquery>

		<cfreturn local.q.model_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="model" type="com.apirone.core.model.bean.Model" required="true">

		<cfset var categories = SerializeJSON( super.getCategoriesAsArray( model.getCategories() ) )>

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				models
			SET
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.model.getStatus().getId()#">,
				model = <cfqueryparam cfsqltype="Varchar" value="#arguments.model.getName()#">,
				code = <cfqueryparam cfsqltype="Varchar" value="#arguments.model.getCode()#">,
				categories = <cfqueryparam cfsqltype="Other" value="#categories#">,
				model_type_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.model.getType().getId()#">,
				fruits_count = <cfqueryparam cfsqltype="Integer" value="#arguments.model.getFruitsCount()#">
			WHERE
				model_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.model.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.model.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="modelId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				models
			WHERE
				model_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.modelId#">::uuid
			RETURNING model_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>
</cfcomponent>
