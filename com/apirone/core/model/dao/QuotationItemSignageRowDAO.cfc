<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="quotationItemSignageRowId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_item_signage_row_id::varchar,
				quotation_item_id::varchar,
				*
			FROM quotation_item_signage_rows
			WHERE quotation_item_signage_row_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemSignageRowId#">::uuid
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationItemId" type="String" required="false">
		<cfargument name="orderBy" type="String" required="true" default="quotation_item_signage_row_id">
		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_item_signage_row_id::varchar,
				quotation_item_id::varchar,
				COUNT(quotation_item_signage_row_id) OVER() AS total
			FROM
				quotation_item_signage_rows
			WHERE 1=1
				<cfif !IsNull( arguments.quotationItemId )>
					AND quotation_item_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationItemId#">::uuid
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
		<cfargument name="quotationItemSignageRow" type="com.apirone.core.model.bean.QuotationItemSignageRow" required="true">
		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_item_signage_rows (
				quotation_item_id,
				text_align,
				content,
				char_count,
				orderby
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemSignageRow.getQuotationItem().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemSignageRow.getTextAlign()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemSignageRow.getContent()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemSignageRow.getCharCount()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemSignageRow.getOrderby()#">
			)
			RETURNING quotation_item_signage_row_id
		</cfquery>
		<cfreturn local.q.quotation_item_signage_row_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="quotationItemSignageRow" type="com.apirone.core.model.bean.QuotationItemSignageRow" required="true">
		<cfquery name="local.q" datasource="apirone">
			UPDATE quotation_item_signage_rows
			SET
				quotation_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemSignageRow.getQuotationItem().getId()#">::uuid,
				text_align = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationItemSignageRow.getTextAlign()#">,
				content = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationItemSignageRow.getContent()#">,
				char_count = <cfqueryparam cfsqltype="INTEGER" value="#arguments.quotationItemSignageRow.getCharCount()#">
				orderby = <cfqueryparam cfsqltype="INTEGER" value="#arguments.quotationItemSignageRow.getOrderby()#">
			WHERE
				quotation_item_signage_row_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemSignageRow.getId()#">::uuid
		</cfquery>
		<cfreturn arguments.quotationItemSignageRow.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="quotationItemSignageRowId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM
				quotation_item_signage_rows
			WHERE
				quotation_item_signage_row_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemSignageRowId#">::uuid
		</cfquery>
		<cfreturn true>
	</cffunction>
</cfcomponent>
