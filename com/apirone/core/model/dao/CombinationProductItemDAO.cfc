<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="combinationProductItemId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				combination_product_item_id::varchar,
				combination_id::varchar,
				product_item_id,
				*
			FROM
				combination_product_items
			WHERE
				combination_product_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.combinationProductItemId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="getByCombinationId" output="false">
		<cfargument name="combinationId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
			combination_product_item_id::varchar,
			*
			FROM
			combination_product_items
			WHERE
			combination_id = <cfqueryparam cfsqltype="varchar" value="#arguments.combinationId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="read1" returntype="Query">
		<cfargument name="productId" type="String" required="true">
		<cfargument name="productItemId" type="String" required="true">
		<cfargument name="parentId" type="String" required="true">
		<cfargument name="attributeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
				FROM product_items
				LEFT JOIN attributes_raw_values ON product_items.attribute_raw_value_id = attributes_raw_values.attribute_raw_value_id
				WHERE
					product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid and
					product_item_id <> <cfqueryparam cfsqltype="Varchar" value="#arguments.productItemId#">::uuid and
					parent_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.parentId#">::uuid and
					attribute_id <> <cfqueryparam cfsqltype="Varchar" value="#arguments.attributeId#">::uuid
				ORDER BY product_item_id
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="combinationProductItem" type="com.apirone.core.model.bean.CombinationProductItem" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO combination_product_items (
				product_item_id,
				combination_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Numeric" value="#arguments.combinationProductItem.getProductItemId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.combinationProductItem.getCombinationId()#">::uuid
			) RETURNING combination_product_item_id
		</cfquery>

		<cfreturn local.q.combination_product_item_id.toString()>
	</cffunction>


	<cffunction name="delete" returntype="Boolean">
		<cfargument name="combinationProductItemId" type="String">

		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM combination_product_items
			WHERE
				combination_product_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.combinationProductItemId#">::uuid
		</cfquery>

		<cfreturn true>
	</cffunction>

	<cffunction name="combinationAlreadyExists" access="public" returntype="boolean">
		<cfargument name="productItemIds" type="array" required="true">

		<cfset var whereClauses = []>

		<cfloop array="#arguments.productItemIds#" index="id">
			<cfset arrayAppend(whereClauses,
					"EXISTS (SELECT 1 FROM combination_product_items WHERE combination_id = c1.combination_id AND product_item_id = " & val(id) & ")"
				)>
		</cfloop>

		<cfset var whereSQL = arrayToList(whereClauses, " AND ")>

		<cfquery name="qCheck" datasource="apirone">
			SELECT c1.combination_id
			FROM combinations c1
			WHERE #preserveSingleQuotes(whereSQL)#
			LIMIT 1
		</cfquery>

		<cfreturn qCheck.recordCount GT 0>
	</cffunction>
</cfcomponent>
