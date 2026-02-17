<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	
	<cffunction name="read" returntype="Query">
		<cfargument name="quotationItemPriceId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				quotation_item_prices
			WHERE
				quotation_item_price_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemPriceId#">
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationItemId" type="String" required="false">
		<cfargument name="productId" type="String" required="false">
		
		<cfargument name="orderBy" type="String" required="true" default="quotation_item_prices.quotation_item_price_id">
		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_item_price_id,
				COUNT(quotation_item_price_id) OVER() AS total
			FROM 
				quotation_item_prices
			WHERE 1=1
				<cfif !IsNull( arguments.quotationItemId )>
					AND quotation_item_prices.quotation_item_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationItemId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.productId )>
					AND quotation_item_prices.product_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.productId#">::uuid
				</cfif>

			ORDER BY
				#super.sanitizeSQL( arguments.orderBy )#
			
			<cfif arguments.limit GT 0>
				LIMIT <cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET <cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>
		
		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="Numeric">
		<cfargument name="quotationItemPrice" type="com.apirone.core.model.bean.QuotationItemPrice" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_item_prices (
				<!--- product_id, --->
				name,
				amount,
				quotation_item_id,
				discount1,
				discount2,
				price_method_id
			) VALUES (
				<!--- <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemPrice.getProductId()#">::uuid, --->
				'',
				<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemPrice.getAmount()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemPrice.getQuotationItemId()#">::uuid,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemPrice.getDiscount1()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemPrice.getDiscount2()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemPrice.getMethod().getId()#">
			)
			RETURNING quotation_item_price_id
		</cfquery>

		<cfreturn local.q.quotation_item_price_id>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="quotationItemPrice" type="com.apirone.core.model.bean.QuotationItemPrice" required="true">

		<!----
		<cfdump var="#arguments.quotationItemPrice#">
		<cfabort>
		---->
		
		<cfquery name="local.q" datasource="apirone">
			UPDATE quotation_item_prices
			SET
				name = '',
				amount = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemPrice.getAmount()#">,
				quotation_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemPrice.getQuotationItemId()#">::uuid,
				discount1 = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemPrice.getDiscount1()#">,
				discount2 = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemPrice.getDiscount2()#">,
				price_method_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemPrice.getMethod().getId()#">
			WHERE
				quotation_item_price_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemPrice.getId()#">
		</cfquery>
		
		<cfreturn arguments.QuotationItemPrice.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="quotationItemId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM
				quotation_item_prices
			WHERE
				quotation_item_price_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemId#">
		</cfquery>
		
		<cfreturn true>
	
	</cffunction>

	<cffunction name="deleteByQuotationItemId" returntype="Boolean">
		<cfargument name="quotationItemId" type="String" required="true">
		
		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM 
				quotation_item_prices
			WHERE
				quotation_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemId#">::uuid
		</cfquery>

		<cfreturn true>	
	
	</cffunction>

</cfcomponent>
