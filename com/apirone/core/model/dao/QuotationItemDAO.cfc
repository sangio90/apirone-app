<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="quotationItemId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_item_id::varchar,
				quotation_id::varchar,
				quotation_zone_id::varchar,
				*
			FROM quotation_items
			WHERE quotation_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemId#">::uuid
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationId" type="String" required="false">
		<cfargument name="quotationZoneId" type="String" required="false">
		<cfargument name="orderBy" type="String" required="true" default="quotation_items.quotation_item_id">
		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_item_id::varchar,
				quotation_items.quotation_id::varchar,
				quotation_zone_id::varchar,
				COUNT(quotation_item_id) OVER() AS total,
				*
			FROM quotation_items
				LEFT JOIN signage_config_items USING (signage_config_item_id)
			WHERE 1=1 
				<cfif !IsNull( arguments.quotationId )>
					AND quotation_items.quotation_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationId#">::uuid
				</cfif>	
				<cfif !IsNull( arguments.quotationZoneId )>
					AND quotation_zone_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationZoneId#">::uuid
				</cfif>
			ORDER BY quotation_items.#super.sanitizeSQL( arguments.orderBy )#
			<cfif arguments.limit GT 0>
				LIMIT <cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET <cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="quotationItem" type="com.apirone.core.model.bean.QuotationItem" required="false">
		<cfargument
			name    ="quotationItemSignage"
			type    ="com.apirone.core.model.bean.QuotationItemSignage"
			required="false"
		>
		<cfif NOT StructKeyExists( arguments, "quotationItem" ) AND NOT StructKeyExists(
			arguments,
			"quotationItemSignage"
		)>
			<cfthrow type="Application" message="Devi passare almeno quotationItem o quotationItemSignage">
		</cfif>
		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_items (
				<cfif IsNull( arguments.quotationItemSignage )>
					quotation_id,
					quotation_zone_id,
					price,
					quantity
				<cfelse>
					quotation_id,
					quotation_zone_id,
					signage_config_item_id,
					price,
					quantity
				</cfif>
			) VALUES (
				<cfif IsNull( arguments.quotationItemSignage )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getQuotation().getId()#">::uuid,
					<cfif NOT IsNull( arguments.quotationItem.getQuotationZone() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getQuotationZone().getId()#">::uuid,
					<cfelse>
						NULL,
					</cfif>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getQuotationZone().getId()#">::uuid,
					<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getPrice()#">,
					<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getQuantity()#">
				<cfelse>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemSignage.getQuotation().getId()#">::uuid,
					<cfif NOT IsNull( arguments.quotationItem.getQuotationZone() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getQuotationZone().getId()#">::uuid,
					<cfelse>
						NULL,
					</cfif>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemSignage.getQuotationZone().getId()#">::uuid,
					<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemSignage.getSignageConfigItem().getId()#">,
					<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemSignage.getPrice()#">,
					<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemSignage.getQuantity()#">
				</cfif>
			)
			RETURNING quotation_item_id
		</cfquery>
		<cfreturn local.q.quotation_item_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="quotationItem" type="com.apirone.core.model.bean.QuotationItem" required="false">
		<cfargument
			name    ="quotationItemSignage"
			type    ="com.apirone.core.model.bean.QuotationItemSignage"
			required="false"
		>
		<cfif NOT StructKeyExists( arguments, "quotationItem" ) AND NOT StructKeyExists(
			arguments,
			"quotationItemSignage"
		)>
			<cfthrow type="Application" message="Devi passare almeno quotationItem o quotationItemSignage">
		</cfif>
		<cfquery name="local.q" datasource="apirone">
			UPDATE quotation_items
			SET
				<cfif !IsNull( arguments.quotationItemSignage )>
					quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemSignage.getQuotation().getId()#">::uuid,
					quotation_zone_id = <cfif NOT IsNull( arguments.quotationItemSignage.getQuotationZone() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemSignage.getQuotationZone().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>,
					signage_config_item_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemSignage.getSignageConfigItem().getId()#">,
					price = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemSignage.getPrice()#">,
					quantity = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemSignage.getQuantity()#">
					font_size = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemSignage.getFontSize()#">,
					chart_count = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemSignage.getCharCount()#">,
					height = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemSignage.getHeight()#">,
					height_in_pixel = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemSignage.getHeightInPixel()#">,
					row_count = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemSignage.getRowCount()#">
				<cfelse>
					quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getQuotation().getId()#">::uuid,
					quotation_zone_id = <cfif NOT IsNull( arguments.quotationItem.getQuotationZone() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getQuotationZone().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>,
					price = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getPrice()#">,
					quantity = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getQuantity()#">
				</cfif>
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
