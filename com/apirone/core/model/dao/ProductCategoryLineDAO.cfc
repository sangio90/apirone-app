<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction returntype="Query" name="read">
		<cfargument name="categoryLineId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM product_category_lines
			WHERE product_category_line_id = <cfqueryparam cfsqltype="Integer" value="#arguments.categoryLineId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="lineId" type="String">
		<cfargument name="categoryId" type="Numeric">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="product_category_line_id">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				product_category_line_id,
				COUNT(product_category_line_id) OVER() AS total
			FROM
				product_category_lines
			WHERE 1=1
				<cfif !IsNull( arguments.lineId )>
					AND product_category_lines.line_id = <cfqueryparam value="#arguments.lineId#" cfsqltype="Varchar">::uuid
				</cfif>

				<cfif !IsNull( arguments.categoryId )>
					AND product_category_lines.product_category_id = <cfqueryparam value="#arguments.categoryId#" cfsqltype="Integer">
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

	<!---
		Recupera tutte le righe complete per una categoria.
		Utilizzato da ProductCategoryLineService.listByCategoryId() per evitare N+1.
	--->
	<cffunction name="findByCategoryId" returntype="Query" access="public">
		<cfargument name="categoryId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				product_category_line_id,
				product_category_id,
				line_id::varchar,
				*
			FROM product_category_lines
			WHERE product_category_id = <cfqueryparam value="#arguments.categoryId#" cfsqltype="Integer">
			ORDER BY product_category_line_id ASC
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="Numeric">
		<cfargument
			name    ="ProductCategoryLine"
			type    ="com.apirone.core.model.bean.ProductCategoryLine"
			required="true"
		>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO product_category_lines (
				product_category_id,
				line_id,
				markup
			)
			VALUES (
				<cfqueryparam cfsqltype="Integer" value="#arguments.ProductCategoryLine.getProductCategory().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.ProductCategoryLine.getLine().getId()#">::uuid,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.ProductCategoryLine.getMarkup()#">
			) RETURNING product_category_line_id
		</cfquery>

		<cfreturn q.product_category_line_id>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument
			name    ="ProductCategoryLine"
			type    ="com.apirone.core.model.bean.ProductCategoryLine"
			required="true"
		>

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				product_category_lines
			SET
				markup_value = <cfqueryparam cfsqltype="Numeric" value="#arguments.ProductCategoryLine.getMarkupValue()#">
			WHERE
				product_category_line_id = <cfqueryparam cfsqltype="Integer" value="#arguments.ProductCategoryLine.getId()#">
		</cfquery>

		<cfreturn arguments.ProductCategoryLine.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="productCategoryLineId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				product_category_lines
			WHERE
				product_category_line_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productCategoryLineId#">
			RETURNING product_category_line_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

	<cffunction name="deleteByParams" returntype="Numeric">
		<cfargument name="lineId" type="String" required="true">
		<cfargument name="productCategoryId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				product_category_lines
			WHERE
				line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
				AND product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productCategoryId#">
			RETURNING product_category_line_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

	<!---
		Recupera in batch più record dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query" access="public">
		<cfargument name="ids" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.ids )>

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM product_category_lines
			WHERE product_category_line_id IN (
				<cfqueryparam value="#idsList#" list="true" cfsqltype="integer">
			)
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>
