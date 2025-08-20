<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="productItemId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_item_product_item_id::varchar,
				quotation_item_product_id::varchar,
				product_item_id::integer,
				origin_id::varchar,
				*
			FROM quotation_item_product_items
			WHERE quotation_item_product_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productItemId#">::uuid
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationItemProductId" type="String" required="false">
		<cfargument name="productItemId" type="String" required="false">
		<cfargument name="originId" type="String" required="false">
		<cfargument name="orderBy" type="String" required="true" default="quotation_item_product_item_id">
		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">
		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_item_product_item_id::varchar,
				quotation_item_product_id::varchar,
				product_item_id::integer,
				origin_id::varchar,
				COUNT(quotation_item_product_item_id) OVER() AS total
			FROM
				quotation_item_product_items
			WHERE 1=1
				<cfif !IsNull( arguments.quotationItemProductId )>
					AND quotation_item_product_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationItemProductId#">::uuid
				</cfif>
				<cfif !IsNull( arguments.productItemId )>
					AND product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productItemId#">
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
		<cfargument name="productItem" type="com.apirone.core.model.bean.QuotationItemProductItem" required="true">
		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_item_product_items (
				quotation_item_product_id,
				product_item_id,
				origin_id
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.productItem.getQuotationItemProduct().getId()#">::uuid,
				<cfqueryparam cfsqltype="Integer" value="#arguments.productItem.getProductItem().getId()#">,
				<cfif !IsNull( arguments.productItem.getOrigin() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.productItem.getOrigin().getId()#">::uuid
				<cfelse>
					NULL
				</cfif>
			)
			RETURNING quotation_item_product_item_id
		</cfquery>
		<cfreturn local.q.quotation_item_product_item_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="productItem" type="com.apirone.core.model.bean.QuotationItemProductItem" required="true">
		<cfquery name="local.q" datasource="apirone">
			UPDATE quotation_item_product_items
			SET
				quotation_item_product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productItem.getQuotationItemProduct().getId()#">::uuid,
				product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productItem.getProductItem().getId()#">
				<cfif !IsNull( arguments.productItem.getOrigin() )>
					,origin_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productItem.getOrigin().getId()#">::uuid
				</cfif>
			WHERE quotation_item_product_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productItem.getId()#">::uuid
		</cfquery>
		<cfreturn arguments.productItem.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="productItemId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				quotation_item_product_items
			WHERE
				quotation_item_product_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productItemId#">::uuid
		</cfquery>
		<cfreturn true>
	</cffunction>
</cfcomponent>
