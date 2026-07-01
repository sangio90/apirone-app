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

	<!---
		Recupera in batch più CombinationProductItem dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query" access="public">
		<cfargument name="ids" type="Array" required="true">

		<cfreturn super.$readByIdsUuid(
			table   = "combination_product_items",
			pkColumn = "combination_product_item_id",
			ids     = arguments.ids
		)>
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
			ORDER BY created_at asc
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Recupera in batch i CombinationProductItem per una lista di combination_id.
		Utilizzato da CombinationService.getMany() per evitare N+1 su buildFromRow.
	--->
	<cffunction name="readByCombinationIds" access="public" returntype="Query">
		<cfargument name="combinationIds" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.combinationIds )>

		<cfquery name="local.q" datasource="apirone">
			SELECT
				combination_product_item_id::varchar,
				*
			FROM combination_product_items
			WHERE combination_id = ANY(
				<cfqueryparam value="#idsList#" list="false" cfsqltype="varchar">::uuid[]
			)
			ORDER BY created_at asc
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument
			name    ="combinationProductItem"
			type    ="com.apirone.core.model.bean.CombinationProductItem"
			required="true"
		>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO combination_product_items (
				product_item_id,
				combination_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Numeric" value="#arguments.combinationProductItem.getProductItem().getId()#">,
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

	<cffunction name="exists" access="public" returntype="boolean">
		<cfargument name="productItemIds" type="array" required="true">

		<cfset var whereClauses = []>

		<cfloop array="#arguments.productItemIds#" index="id">
			<cfset ArrayAppend(
				whereClauses,
				"EXISTS (SELECT 1 FROM combination_product_items WHERE combination_id = c1.combination_id AND product_item_id = " & Val(
					id
				) & ")"
			)>
		</cfloop>

		<cfset var whereSQL = ArrayToList( whereClauses, " AND " )>

		<cfquery name="check" datasource="apirone">
			SELECT
				c1.combination_id
			FROM
				combinations c1
			WHERE
				#PreserveSingleQuotes( whereSQL )#
			LIMIT 1
		</cfquery>

		<cfreturn check.recordCount GT 0>
	</cffunction>

</cfcomponent>
