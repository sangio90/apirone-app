<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="quotationItemId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_item_id::varchar,
				quotation_id::varchar,
				*
			FROM quotation_items
			WHERE quotation_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemId#">::uuid
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationId" type="String" required="false">
		<cfargument name="orderBy" type="String" required="true" default="quotation_items.quotation_item_id">
		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_item_id::varchar,
				quotation_id::varchar,
				COUNT(quotation_item_id) OVER() AS total
			FROM quotation_items
			WHERE 1=1
				<cfif !IsNull( arguments.quotationId )>
					AND quotation_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationId#">::uuid
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
		<cfargument name="quotationItem" type="com.apirone.core.model.bean.QuotationItem" required="true">
		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_items (
				quotation_id,
				price,
				quantity
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getQuotation().getId()#">::uuid,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getPrice()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getQuantity()#">
			)
			RETURNING quotation_item_id
		</cfquery>
		<cfreturn local.q.quotation_item_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="quotationItem" type="com.apirone.core.model.bean.QuotationItem" required="true">
		<cfquery name="local.q" datasource="apirone">
			UPDATE quotation_items
			SET
				quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getQuotation().getId()#">::uuid,
				price = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getPrice()#">,
				quantity = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getQuantity()#">
			WHERE
				quotation_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getId()#">::uuid
		</cfquery>
		<cfreturn arguments.quotationItem.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="quotationItemId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM quotation_items
			WHERE
				quotation_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemId#">::uuid
		</cfquery>
		<cfreturn true>
	</cffunction>
</cfcomponent>
