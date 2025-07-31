<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="productId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_item_product_id::varchar,
				product_id::varchar,
				quotation_item_id::varchar,
				parent_id::varchar,
				*
			FROM
				quotation_item_products
			WHERE
				quotation_item_product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationItemId" type="String" required="false">
		<cfargument name="parentId" type="String" required="false">
		<cfargument name="productId" type="String" required="false">
		<cfargument name="orderBy" type="String" required="true" default="quotation_item_product_id">
		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_item_product_id::varchar,
				product_id::varchar,
				quotation_item_id::varchar,
				parent_id::varchar,
				COUNT(quotation_item_product_id) OVER() AS total
			FROM
				quotation_item_products
			WHERE 1=1
				<cfif !IsNull( arguments.quotationItemId )>
					AND quotation_item_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationItemId#">::uuid
				</cfif>
				<cfif !IsNull( arguments.productId )>
					AND product_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.productId#">::uuid
				</cfif>
				<cfif !IsNull( arguments.parentId )>
					AND parent_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.parentId#">::uuid
				</cfif>
			ORDER BY #super.sanitizeSQL( arguments.orderBy )#

			<cfif arguments.limit GT 0>
				LIMIT <cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET <cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="product" type="com.apirone.core.model.bean.QuotationItemProduct" required="true">
		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_item_products (
				quotation_item_id,
				product_id,
				parent_id
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.product.getQuotationItem().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.product.getProduct().getId()#">::uuid,
				<cfif !IsNull( arguments.product.getParent() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.product.getParent().getId()#">::uuid
				<cfelse>
					NULL
				</cfif>
			)
			RETURNING quotation_item_product_id
		</cfquery>
		<cfreturn local.q.quotation_item_product_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="product" type="com.apirone.core.model.bean.QuotationItemProduct" required="true">
		<cfquery name="local.q" datasource="apirone">
			UPDATE quotation_item_products
			SET
				quotation_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.product.getQuotationItem().getId()#">::uuid,
				product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.product.getProduct().getId()#">::uuid
				<cfif !IsNull( arguments.product.getParent() )>
					,parent_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.product.getParent().getId()#">::uuid
				</cfif>
			WHERE
				quotation_item_product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.product.getId()#">::uuid
		</cfquery>
		<cfreturn arguments.product.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="productId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM
				quotation_item_products
			WHERE
				quotation_item_product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
		</cfquery>
		<cfreturn true>
	</cffunction>
</cfcomponent>
