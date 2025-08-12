<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="lineId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT line_id::varchar, model_id::varchar, *
			FROM
				linemodels
			WHERE
				linemodel_id = <cfqueryparam cfsqltype="varchar" value="#arguments.lineId#">::uuid
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
				linemodel_id::varchar,
				COUNT(linemodel_id) OVER() AS total
			FROM
				linemodels
			WHERE 1=1

				<cfif !IsNull( arguments.categoryId )>
					AND linemodels.product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.categoryId#">
				</cfif>

				<cfif !IsNull( arguments.modelId )>
					AND linemodels.model_id = <cfqueryparam cfsqltype="Integer" value="#arguments.modelId#">
				</cfif>

				<cfif !IsNull( arguments.lineId )>
					AND linemodels.line_id = <cfqueryparam cfsqltype="Integer" value="#arguments.lineId#">
				</cfif>

				<cfif !IsNull( arguments.statusId )>
					AND linemodels.status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.statusId#">
				</cfif>

				<cfif !IsNull( arguments.str )>
					AND
					(
						linemodels.linemodel ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
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
		<cfargument name="lineModel" type="com.apirone.core.model.bean.Line" required="true">

		<cfset var categories = super.getCategoriesAsArray( line.getCategories() )>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO linemodels (
				line_id,
				model_id,
				product_category_id
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.lineModel.getLine().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.lineModel.getModel().getId()#">::uuid,
				<cfqueryparam cfsqltype="Integer" value="#arguments.lineModel.getCategory().getId()#">
			) RETURNING linemodel_id
		</cfquery>

		<cfreturn local.q.linemodel_id.toString()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="lineModelId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				linemodels
			WHERE
				linemodel_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineModelId#">::uuid
			RETURNING linemodel_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>
</cfcomponent>
