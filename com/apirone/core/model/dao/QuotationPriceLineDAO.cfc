<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	
	<cffunction name="read" returntype="Query">
		<cfargument name="quotationPriceLineId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				quotation_price_lines
			WHERE
				quotation_price_line_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationPriceLineId#">
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationPriceId" type="String" required="false">
		
		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_price_line_id,
				COUNT(quotation_price_line_id) OVER() AS total
			FROM 
				quotation_price_lines
			WHERE 1=1

				<cfif !IsNull( arguments.quotationPriceId )>
					AND quotation_price_lines.quotation_price_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationPriceId#">
				</cfif>

			ORDER BY
				#super.sanitizeSQL( arguments.orderBy )#
		</cfquery>
		
		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="Numeric">
		<cfargument name="quotationPriceLine" type="com.apirone.core.model.bean.QuotationItemPriceLine" required="true">

		<cfscript>
			cffile( action="append", file="#ExpandPath('/debug.log')#", output="QuotationItemPriceLineService: create line, productItemId: #quotationItemPriceLine.getQuotationItemPriceId()#, price: #quotationItemPriceLine.getAmount()#");
		</cfscript>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_price_lines (
				name,
				amount,
				quotation_price_id
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationPriceLine.getName()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationPriceLine.getAmount()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.quotationPriceLine.getQuotationPriceId()#">
			)
			RETURNING quotation_price_line_id
		</cfquery>
		<cfreturn local.q.quotation_price_line_id>
	</cffunction>

	<cffunction name="update" returntype="Numeric">
		<cfargument name="quotationPriceLine" type="com.apirone.core.model.bean.QuotationPriceLine" required="true">
		<cfquery name="local.q" datasource="apirone">
			UPDATE quotation_price_lines
			SET
				name = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationPriceLine.getName()#">,
				amount = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationPriceLine.getAmount()#">,
				quotation_price_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationPriceLine.getQuotationPriceId()#">
			WHERE
				quotation_price_line_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationPriceLine.getId()#">
		</cfquery>
		<cfreturn arguments.quotationPriceLine.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="quotationPriceLineId" type="Numeric" required="true">
		<cfquery name="local.q" datasource="apirone" result="result">
			DELETE
			FROM 
				quotation_price_lines
			WHERE
				quotation_price_line_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationPriceLineId#">
		</cfquery>
		<cfreturn result.recordCount>
	</cffunction>

	<cffunction name="deleteByQuotationPriceId" returntype="Numeric">
		<cfargument name="quotationPriceId" type="Numeric" required="true">
		<cfquery name="local.q" datasource="apirone" result="result">
			DELETE
			FROM 
				quotation_price_lines
			WHERE
				quotation_price_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationPriceId#">
		</cfquery>
		<cfreturn result.recordCount>
	</cffunction>

</cfcomponent>
