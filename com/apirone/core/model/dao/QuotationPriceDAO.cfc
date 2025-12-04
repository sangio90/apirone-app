<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	
	<cffunction name="read" returntype="Query">
		<cfargument name="quotationPriceId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				quotation_prices
			WHERE
				quotation_price_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationPriceId#">
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationId" type="String" required="false">
		
		<cfargument name="orderBy" type="String" required="true" default="quotation_prices.quotation_price_id">
		<cfargument name="limit" type="Numeric" required="true" default="20">
		<cfargument name="offset" type="Numeric" required="true" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_price_id,
				COUNT(quotation_price_id) OVER() AS total
			FROM 
				quotation_prices
			WHERE 1=1
				<cfif !IsNull( arguments.quotationId )>
					AND quotation_prices.quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationId#">::uuid
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
		<cfargument name="quotationPrice" type="com.apirone.core.model.bean.QuotationPrice" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_pricess (
				name,
				amount,
				quotation_id,
				discount1,
				discount2,
				shipment_cost,
				price_method_id
			) VALUES (
				<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationPrice.getName()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationPrice.getAmount()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationPrice.getQuotationId()#">::uuid,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationPrice.getDiscount1()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationPrice.getDiscount2()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationPrice.getShippingMethod().getCost()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationPrice.getMethod().getId()#">
			)
			RETURNING quotation_price_id
		</cfquery>

		<cfreturn local.q.quotation_price_id>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="quotationPrice" type="com.apirone.core.model.bean.QuotationPrice" required="true">
		
		<cfquery name="local.q" datasource="apirone">
			UPDATE quotation_prices
			SET
				amount = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationPrice.getAmount()#">,
				quotation_item_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationPrice.getDiscount1()#">,
				discount1 = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationPrice.getDiscount1()#">,
				discount2 = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationPrice.getDiscount2()#">,
				shipment_cost = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationPrice.getShippingMethod().getCost()#">
			WHERE
				quotation_price_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationPrice.getId()#">
		</cfquery>
		
		<cfreturn arguments.quotationPrice.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="quotationPriceId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM
				quotation_prices
			WHERE
				quotation_price_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationPriceId#">
		</cfquery>
		
		<cfreturn true>
	
	</cffunction>

	<cffunction name="deleteByQuotationId" returntype="Boolean">
		<cfargument name="quotationId" type="String" required="true">
		
		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM 
				quotation_prices	
			WHERE
				quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationId#">::uuid
		</cfquery>

		<cfreturn true>	
	
	</cffunction>

</cfcomponent>
