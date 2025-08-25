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

	<cffunction name="find" returntype="Query">
		<cfargument name="productId" type="String">
		<cfargument name="originId" type="Numeric">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				product_item_id, origin_id
			FROM
				product_items
			WHERE 1=1

				AND origin_id
					<cfif IsNull( arguments.originId )>
						IS NULL
					<cfelse>
						= <cfqueryparam cfsqltype="Integer" value="#arguments.originId#">
					</cfif>

				<cfif !IsNull( arguments.productId )>
					AND product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
				</cfif>

			ORDER BY
				orderby
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="productItem" type="com.apirone.core.model.bean.ProductItem" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO product_items (
				attribute_raw_value_id,
				product_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.productItem.getAttributeValue().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.productItem.getProductId()#">
			) RETURNING product_item_id
		</cfquery>

		<cfreturn local.q.product_item_id>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="attributeId" type="String">
		<cfargument name="productId" type="String">
		<cfargument name="productItemId" type="String">

		<cfif IsNull( arguments.productItemId )
		AND IsNull( arguments.productId )
		AND IsNull( arguments.attributeId )>
			<cfthrow type="apirone.error.NoArgumentsPassed" message="At least one parameter is required to delete">
		</cfif>

		<cfquery datasource="apirone">
			DELETE
			FROM product_items
			WHERE 1=1

				<cfif !IsNull( arguments.productItemId )>
					AND product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productItemId#">
				</cfif>

				<cfif !IsNull( arguments.productId )>
					AND product_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productId#">
				</cfif>

				<cfif !IsNull( arguments.attributeId )>
					AND attribute_raw_value_id IN (
						SELECT attribute_raw_value_id
						FROM attributes_raw_values
						WHERE attribute_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attributeId#">
					)
				</cfif>
		</cfquery>

		<!---
			<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM product_items
			WHERE
			product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productItemId#">
			</cfquery>
			-
		--->

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
</cfcomponent>
