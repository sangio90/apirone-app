<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="productId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_item_product_id::varchar,
				product_id::varchar,
				quotation_item_id::varchar,
				origin_id::varchar,
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
		<cfargument name="originId" type="String" required="false">
		<cfargument name="productId" type="String" required="false">
		<cfargument name="orderBy" type="String" required="true" default="quotation_item_product_id">
		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_item_product_id::varchar,
				product_id::varchar,
				quotation_item_id::varchar,
				origin_id::varchar,
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
				<cfif !IsNull( arguments.originId )>
					AND origin_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.originId#">::uuid
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
				origin_id
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.product.getQuotationItem().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.product.getProduct().getId()#">::uuid,
				<cfif !IsNull( arguments.product.getOrigin() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.product.getOrigin().getId()#">::uuid
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
				<cfif !IsNull( arguments.product.getOrigin() )>
					,origin_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.product.getOrigin().getId()#">::uuid
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

	<!---
		Recupera in batch più QuotationItemProduct dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query" access="public">
		<cfargument name="ids" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.ids )>

		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_item_product_id::varchar,
				product_id::varchar,
				quotation_item_id::varchar,
				origin_id::varchar,
				*
			FROM quotation_item_products
			WHERE quotation_item_product_id = ANY(
				<cfqueryparam value="#idsList#" list="false" cfsqltype="varchar">::uuid[]
			)
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>
