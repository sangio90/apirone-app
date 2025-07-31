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
				product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.roductItemId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="productId" type="String">
		<cfargument name="parentId" type="Numeric">
		<cfargument name="attributeId" type="String">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				product_item_id, parent_id
			FROM
				product_items
				<cfif !IsNull( arguments.attributeId )>
					INNER JOIN attributes_raw_values USING ( attribute_raw_value_id )
						INNER JOIN attributes USING ( attribute_id )
				</cfif>
					--INNER JOIN attributes_raw_values USING ( attribute_raw_value_id )
			WHERE 1=1

				AND parent_id
					<cfif IsNull( arguments.parentId )>
						IS NULL
					<cfelse>
						= <cfqueryparam cfsqltype="Integer" value="#arguments.parentId#">
					</cfif>

				<cfif !IsNull( arguments.productId )>
					AND product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
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
				status_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Integer" value="#arguments.ProductItem.getAttributeValue().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.ProductItem.getProductId()#">::uuid,
				<cfqueryparam cfsqltype="Integer" value="#arguments.ProductItem.getOrderBy()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.ProductItem.getStatus().getId()#">
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

		<cfif IsNull( arguments.productItemId )
		AND IsNull( arguments.productId )
		AND IsNull( arguments.attributeId )>
			<cfthrow type="ApirOne.errors.NoArgumentsPassed" message="At least one parameter is required to delete">
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
