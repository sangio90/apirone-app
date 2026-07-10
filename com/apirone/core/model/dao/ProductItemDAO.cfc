<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="productItemId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				product_id::varchar,
				*
			FROM
				product_items
			WHERE
				product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productItemId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Recupera in batch più record dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query" access="public">
		<cfargument name="ids" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.ids )>

		<cfquery name="local.q" datasource="apirone">
			SELECT
				product_id::varchar,
				*
			FROM product_items
			WHERE product_item_id IN (
				<cfqueryparam value="#idsList#" list="true" cfsqltype="integer">
			)
			ORDER BY
				orderby ASC
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Query piatta per il profilo treelight: join con attributes_raw_values per evitare
		un secondo round-trip. Usata da ProductItemService.listForTreelight().
	--->
	<cffunction name="findForTreelight" returntype="Query" access="public">
		<cfargument name="productId" type="String" required="true">
		<cfargument name="originId" type="Numeric">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				pi.product_item_id,
				pi.origin_id,
				pi.important,
				pi.orderby,
				arv.attribute_raw_value_id,
				arv.attribute_id::varchar AS attribute_id,
				arv.allow_note,
				arv.raw_value_id
			FROM product_items pi
			INNER JOIN attributes_raw_values arv USING ( attribute_raw_value_id )
			WHERE pi.product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
				<cfif !IsNull( arguments.originId )>
					AND pi.origin_id = <cfqueryparam cfsqltype="Integer" value="#arguments.originId#">
				<cfelse>
					AND pi.origin_id IS NULL
				</cfif>
			ORDER BY pi.orderby ASC
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="productId" type="String">
		<cfargument name="originId" type="Numeric">
		<cfargument name="attributeId" type="String">
		<cfargument name="skipOriginId" type="Boolean" default="false">

		<cfquery name="local.q" datasource="apirone" result="local.result">
			SELECT
				product_item_id, origin_id, attribute_raw_value_id,
				COUNT(product_item_id) OVER() AS total
			FROM
				product_items
				<cfif !IsNull( arguments.attributeId )>
					INNER JOIN attributes_raw_values USING ( attribute_raw_value_id )
						INNER JOIN attributes USING ( attribute_id )
				</cfif>
			WHERE 1=1

				<cfif !IsNull( arguments.productId )>
					AND product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
				</cfif>

				<!--- TODO: use 'O' for "IS NULL" --->
				<cfif !arguments.skipOriginId>
					AND origin_id
						<cfif IsNull( arguments.originId )>
							IS NULL
						<cfelse>
							= <cfqueryparam cfsqltype="Integer" value="#arguments.originId#">
						</cfif>
				</cfif>

				<cfif !IsNull( arguments.attributeId )>
					AND attributes.attribute_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attributeId#">::uuid
				</cfif>

			ORDER BY
				product_items.orderby ASC
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="Numeric">
		<cfargument name="ProductItem" type="com.apirone.core.model.bean.ProductItem" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO product_items (
				attribute_raw_value_id,
				product_id,
				orderby,
				status_id,
				origin_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Integer" value="#arguments.ProductItem.getAttributeValue().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.ProductItem.getProductId()#">::uuid,
				<cfqueryparam cfsqltype="Integer" value="#arguments.ProductItem.getOrderBy()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.ProductItem.getStatus().getId()#">,
				<cfif IsNull( arguments.ProductItem?.getOrigin()?.getId() )>
					NULL
				<cfelse>
					<cfqueryparam cfsqltype="Integer" value="#arguments.ProductItem.getOrigin().getId()#">
				</cfif>
			) RETURNING product_item_id
		</cfquery>

		<cfreturn local.q.product_item_id>
	</cffunction>

	<cffunction name="update" returntype="Numeric">
		<cfargument name="ProductItem" type="com.apirone.core.model.bean.ProductItem" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				product_items
			SET
				orderby = <cfqueryparam cfsqltype="Integer" value="#arguments.ProductItem.getOrderBy()#">,
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.ProductItem.getStatus().getId()#">
			WHERE
				product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.ProductItem.getId()#">
		</cfquery>

		<cfreturn arguments.ProductItem.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="attributeId" type="String">
		<cfargument name="productId" type="String">
		<cfargument name="productItemId" type="String">

		<cfif IsNull( arguments.productItemId ) AND IsNull( arguments.productId ) AND IsNull( arguments.attributeId )>
			<cfthrow type="apirone.error.NoArgumentsPassed" message="At least one parameter is required to delete">
		</cfif>

		<cfquery datasource="apirone" result="result" name="local.q">
			DELETE
			FROM product_items
			WHERE 1=1

				<cfif !IsNull( arguments.productItemId )>
					AND product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productItemId#">
				</cfif>

				<cfif !IsNull( arguments.productId )>
					AND product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.attributeId )>
					AND attribute_raw_value_id IN (
						SELECT attribute_raw_value_id
						FROM attributes_raw_values
						WHERE attribute_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attributeId#">
					)
				</cfif>
			RETURNING
				product_item_id
		</cfquery>

		<cfreturn true>
	</cffunction>

	<cffunction name="deleteComponents" returntype="Boolean">
		<cfargument name="productItemId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM components
			WHERE
				product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productItemId#">
		</cfquery>

		<cfreturn true>
	</cffunction>

	<!---
		Recupera in batch tutti i ProductItem collegati a una lista di productId.
		Utilizzato da ProductItemService.listByProductIds() per pre-caricare item in blocco.
	--->
	<cffunction name="findByProductIds" returntype="Query" access="public">
		<cfargument name="productIds" type="Array" required="true">

		<!--- Converte l'array di ID in lista per la clausola IN --->
		<cfset var idsList = ArrayToList(arguments.productIds)>

		<cfquery name="local.q" datasource="apirone">
			SELECT
				product_id::varchar,
				*
			FROM product_items
			WHERE product_id = ANY(
				ARRAY[<cfqueryparam value="#idsList#" list="true" cfsqltype="varchar">]::uuid[]
			)
			ORDER BY
				orderby ASC
		</cfquery>

		<cfreturn local.q>
	</cffunction>

</cfcomponent>
