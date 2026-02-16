<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	
	<cffunction name="read" returntype="Query">
		<cfargument name="quotationItemPriceLineId" type="Numeric" required="true">
		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				quotation_item_price_lines
			WHERE
				quotation_item_price_line_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemPriceLineId#">
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationItemPriceId" type="String" required="false">
		<cfargument name="productId" type="String" required="false">
		
		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_item_price_line_id,
				COUNT(quotation_item_price_line_id) OVER() AS total
			FROM 
				quotation_item_price_lines
			WHERE 1=1

				<cfif !IsNull( arguments.quotationItemPriceId )>
					AND quotation_item_price_lines.quotation_item_price_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemPriceId#">
				</cfif>

				<cfif !IsNull( arguments.productId )>
					AND quotation_item_price_lines.product_id = <cfqueryparam cfsqltype="Other" value="#arguments.productId#">
				</cfif>

			ORDER BY
				#super.sanitizeSQL( arguments.orderBy )#
		</cfquery>
		
		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="Numeric">
		<cfargument name="quotationItemPriceLine" type="com.apirone.core.model.bean.QuotationItemPriceLine" required="true">

		<cfscript>
		cffile( action="append", file="#ExpandPath('/debug.log')#", output="QuotationItemPriceLineDAO: before create line, quotationItemPriceLine: #quotationItemPriceLine.getQuotationItemPriceId()#, price: #quotationItemPriceLine.getAmount()#");
		</cfscript>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_item_price_lines (
				name,
				amount,
				cost,
				quotation_item_price_id
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemPriceLine.getName()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemPriceLine.getAmount()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemPriceLine.getCost()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemPriceLine.getQuotationItemPriceId()#">
			)
			RETURNING quotation_item_price_line_id
		</cfquery>

		<cfscript>
		cffile( action="append", file="#ExpandPath('/debug.log')#", output="QuotationItemPriceLineDAO: after create line: id: #local.q.quotation_item_price_line_id#");
		</cfscript>

		<cfreturn local.q.quotation_item_price_line_id>
	</cffunction>

	<cffunction name="update" returntype="Numeric">
		<cfargument name="quotationItemPriceLine" type="com.apirone.core.model.bean.QuotationItemPriceLine" required="true">
		<cfquery name="local.q" datasource="apirone">
			UPDATE quotation_items_price_lines
			SET
				name = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemPriceLine.getName()#">,
				amount = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemPriceLine.getAmount()#">,
				cost = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemPriceLine.getCost()#">,
				quotation_item_price_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemPriceLine.getQuotationItemPriceId()#">
			WHERE
				quotation_item_price_line_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemPriceLine.getId()#">
		</cfquery>
		<cfreturn arguments.quotationItemPriceLine.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="quotationItemPriceLineId" type="Numeric" required="true">
		<cfquery name="local.q" datasource="apirone" result="result">
			DELETE
			FROM 
				quotation_item_price_lines
			WHERE
				quotation_item_price_line_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemPriceLineId#">
		</cfquery>
		<cfreturn result.recordCount>
	</cffunction>

	<cffunction name="deleteByQuotationItemPriceId" returntype="Numeric">
		<cfargument name="quotationItemPriceId" type="Numeric" required="true">
		<cfquery name="local.q" datasource="apirone" result="result">
			DELETE
			FROM 
				quotation_item_price_lines
			WHERE
				quotation_item_price_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemPriceId#">
		</cfquery>
		<cfreturn result.recordCount>
	</cffunction>

</cfcomponent>
