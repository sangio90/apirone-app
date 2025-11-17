<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="quotationItemFruitId" type="Numeric" required="true">
		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				quotation_item_fruits
			WHERE
				quotation_item_fruit_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemFruitId#">
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationItemId" type="String" required="false">
		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">
		<cfargument name="orderby" type="String" required="true" default="created_at DESC">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_item_fruit_id,
				COUNT(quotation_item_fruit_id) OVER() AS total
			FROM
				quotation_item_fruits
			WHERE 1=1

				<cfif !IsNull( arguments.quotationItemId )>
					AND quotation_item_fruits.quotation_item_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationItemId#">::uuid
				</cfif>

			ORDER BY
				#super.sanitizeSQL( arguments.orderBy )#
			<cfif arguments.limit GT 0>
				LIMIT
					<cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET
					<cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="Numeric">
		<cfargument name="quotationItemFruit" type="com.apirone.core.model.bean.QuotationItemFruit" required="true">
		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_item_fruits (
				quotation_item_id,
				position,
				product_id,
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemFruit.getId()#">::uuid,
				<cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemFruit.getPosition()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemFruit.getProduct().getId()#">::uuid,
			)
			RETURNING quotation_item_fruit_id
		</cfquery>
		<cfreturn local.q.quotation_item_fruit_id>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="quotationItem" type="com.apirone.core.model.bean.QuotationItem" required="true">
		<cfquery name="local.q" datasource="apirone">
			UPDATE quotation_items
			SET
				quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getQuotation().getId()#">::uuid,
				quotation_zone_id =
					<cfif NOT IsNull( arguments.quotationItem.getQuotationZone() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getQuotationZone().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>,
				product_id =
					<cfif NOT IsNull( arguments.quotationItem.getProduct() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getProduct().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>,
				price = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getPrice()#">,
				quantity = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getQuantity()#">
				<cfif IsInstanceOf( arguments.quotationItem, "com.apirone.core.model.bean.QuotationItemSignage" )>
					,
					signage_config_item_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getSignageConfigItem().getId()#">,
					char_count             = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getSignageConfigItem().getCharCount()#">,
					height                 = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getSignageConfigItem().getHeight()#">,
					height_in_pixel        = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getSignageConfigItem().getHeightInPixel()#">,
					row_count              = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getSignageConfigItem().getRowCount()#">
				</cfif>
			WHERE
				quotation_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getId()#">::uuid
		</cfquery>
		<cfreturn arguments.quotationItem.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="quotationItemFruitId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM quotation_items
			WHERE
				quotation_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemFruitId#">::uuid
		</cfquery>
		<cfreturn true>
	</cffunction>
</cfcomponent>
