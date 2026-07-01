<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="finishId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				finish_id::varchar,
				categories::varchar,
				*
			FROM
				finishes
			WHERE
				finish_id = <cfqueryparam cfsqltype="varchar" value="#arguments.finishId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Recupera in batch più record dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query">
		<cfargument name="ids" type="Array" required="true">

		<cfif ArrayLen( arguments.ids ) EQ 0>
			<cfreturn QueryNew( "finish_id" )>
		</cfif>

		<cfset var idsList = ArrayToList( arguments.ids )>

		<cfquery name="local.q" datasource="apirone">
			SELECT
				finish_id::varchar,
				categories::varchar,
				*
			FROM finishes
			WHERE finish_id = ANY(
				<cfqueryparam value="#idsList#" list="false" cfsqltype="varchar">::uuid[]
			)
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="readByCode" returntype="Query">
		<cfargument name="code" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				finish_id::varchar,
				categories::varchar,
				*
			FROM
				finishes
			WHERE
				code = <cfqueryparam cfsqltype="varchar" value="#arguments.code#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String">
		<cfargument name="categoryId" type="Numeric">
		<cfargument name="productCategoryId" type="Numeric">
		<cfargument name="lineId" type="String">
		<cfargument name="langId" type="String" default="IT">
		<cfargument name="orderBy" type="String" default="finishes.code asc, finishes.finish_id">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT DISTINCT
				<cfif arguments.orderBy CONTAINS "texts.text">
					texts.text,
				</cfif>
				finish_id::varchar,
				categories::varchar,
				finishes.code,
				COUNT( finish_id ) OVER() AS total
			FROM
				finishes
					INNER JOIN texts USING ( finish_id )

				<cfif !IsNull( arguments.lineId )>
					INNER JOIN products USING ( finish_id )
						LEFT JOIN catalog_bundles USING ( catalog_bundle_id )
				</cfif>

			WHERE 1=1

				<cfif !IsNull( arguments.langId )>
					AND texts.lang_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.langId#">
				</cfif>

				<cfif !IsNull( arguments.categoryId )>
					<!--- INFO: with cfqueryparam not works --->
					AND categories @> ANY ('{[#super.sanitizeSQL( arguments.categoryId )#]}')
				</cfif>

				<cfif !IsNull( arguments.lineId )>
					AND catalog_bundles.line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.productCategoryId )>
					AND catalog_bundles.product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productCategoryId#">
				</cfif>

				<cfif !IsNull( arguments.statusId )>
					AND finishes.status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.statusId#">
				</cfif>

				<cfif !IsNull( arguments.str )>
					AND (
						finishes.code ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
						OR texts.text ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
					)
				</cfif>

			ORDER BY
				#super.sanitizeSQL( arguments.orderBy )#

			<cfif arguments.limit GTE 0>
				LIMIT
					<cfqueryparam cfsqltype="integer" value="#arguments.limit#">
				OFFSET
					<cfqueryparam cfsqltype="integer" value="#arguments.offset#">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="finish" type="com.apirone.core.model.bean.Finish" required="true">

		<cfset var categories = super.getCategoriesAsArray( finish.getCategories() )>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO finishes (
				code,
				status_id,
				categories
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.finish.getCode()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.finish.getStatus().getId()#">,
				<cfqueryparam cfsqltype="Other" value="#SerializeJSON( categories )#">
			) RETURNING finish_id
		</cfquery>

		<cfreturn local.q.finish_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="finish" type="com.apirone.core.model.bean.Finish" required="true">

		<cfset var categories = super.getCategoriesAsArray( finish.getCategories() )>

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				finishes
			SET
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.finish.getStatus().getId()#">,
				code = <cfqueryparam cfsqltype="Varchar" value="#arguments.finish.getCode()#">,
				categories = <cfqueryparam cfsqltype="Other" value="#SerializeJSON( categories )#">
			WHERE
				finish_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.finish.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.finish.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="finishId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				finishes
			WHERE
				finish_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.finishId#">::uuid
			RETURNING finish_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>
</cfcomponent>
