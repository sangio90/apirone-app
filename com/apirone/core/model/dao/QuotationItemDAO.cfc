<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="quotationItemId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_item_id::varchar,
				quotation_id::varchar,
				quotation_zone_id::varchar,
				*
			FROM
				quotation_items
			WHERE
				quotation_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemId#">::uuid
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationId" type="String" required="false">
		<cfargument name="quotationZoneId" type="String" required="false">
		<cfargument name="quotationZoneOriginId" type="String" required="false">
		<cfargument name="typeId" type="String" required="false">
		<cfargument name="orderBy" type="String" required="true" default="quotation_items.quotation_item_id">
		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_item_id::varchar,
				quotation_items.quotation_id::varchar,
				quotation_zone_id::varchar,
				COUNT(quotation_item_id) OVER() AS total
			FROM quotation_items
				
				<cfif !IsNull( arguments.typeId )>
					INNER JOIN products ON quotation_items.product_id = products.product_id
					<cfif arguments.typeId EQ "ART">
						INNER JOIN articles ON quotation_items.article_id = articles.article_id
					</cfif>
					INNER JOIN catalog_bundles ON catalog_bundles.catalog_bundle_id = products.catalog_bundle_id
					INNER JOIN product_categories ON catalog_bundles.product_category_id = product_categories.product_category_id
				</cfif>
			WHERE 1=1

				<cfif !IsNull( arguments.quotationId )>
					AND quotation_items.quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.quotationZoneId )>
					AND quotation_zone_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationZoneId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.typeId )>
					<cfif arguments.typeId EQ "ART">
						AND quotation_items.article_id IS NOT NULL
					<cfelse>
						AND product_categories.product_category_type_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.typeId#">
					</cfif>
				</cfif>
			ORDER BY
				quotation_items.#super.sanitizeSQL( arguments.orderBy )#

				<cfif arguments.limit GT 0>
					LIMIT <cfqueryparam value="#arguments.limit#" cfsqltype="integer">
					OFFSET <cfqueryparam value="#arguments.offset#" cfsqltype="integer">
				</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="quotationItem" type="com.apirone.core.model.bean.QuotationItem" required="true">

		<!--- <cfset var price = arguments.quotationItem.getPrice()> ---->

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_items (
				special,
				status_id,
				quotation_id,
				quotation_zone_id,
				product_id,
				article_id,
				<!---
				discount1,
				discount2,
				price_method_id,
				price_goods,
				price_final,
				---->
				quantity,
				"hash"
				<cfif IsInstanceOf( arguments.quotationItem, "com.apirone.core.model.bean.QuotationItemSignage" )>
					,
					signage_config_item_id,
					char_count,
					height,
					height_in_pixel,
					row_count
				</cfif>
			) VALUES (
				<cfqueryparam cfsqltype="Boolean" value="#arguments.quotationItem.getSpecial()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getStatus().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getQuotation().getId()#">::uuid,
				<cfif NOT IsNull( arguments.quotationItem.getQuotationZone() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getQuotationZone().getId()#">::uuid,
				<cfelse>
					NULL,
				</cfif>
				<cfif NOT IsNull( arguments.quotationItem.getProduct() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getProduct().getId()#">::uuid,
				<cfelse>
					NULL,
				</cfif>
				<cfif NOT IsNull( arguments.quotationItem.getArticle() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getArticle().getId()#">::uuid,
				<cfelse>
					NULL,
				</cfif>
				<!-----
				<cfqueryparam cfsqltype="Float" value="#price.getDiscount1()#">,
				<cfqueryparam cfsqltype="Float" value="#price.getDiscount2()#">,
				<cfqueryparam cfsqltype="Varchar" value="#price.getMethod().getId()#">,
				<cfqueryparam cfsqltype="Numeric" value="#price.getTotalGoods()#">,
				<cfqueryparam cfsqltype="Numeric" value="#price.getTotal()#">,
				----->
				<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getQuantity()#">,
				<cfif NOT IsNull( arguments.quotationItem.getHash() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getHash()#">
				<cfelse>
					NULL
				</cfif>
				<cfif IsInstanceOf( arguments.quotationItem, "com.apirone.core.model.bean.QuotationItemSignage" )>
					,
					<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getSignageConfigItem().getId()#">,
					<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getSignageConfigItem().getCharCount()#">,
					<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getSignageConfigItem().getHeight()#">,
					<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getSignageConfigItem().getHeightInPixel()#">,
					<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getSignageConfigItem().getRowCount()#">
				</cfif>
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
				special = <cfqueryparam cfsqltype="Boolean" value="#arguments.quotationItem.getSpecial()#">,
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getStatus().getId()#">,
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
				article_id =
					<cfif NOT IsNull( arguments.quotationItem.getArticle() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getArticle().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>,
				<!---- price = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getPrice()#">, ---->
				quantity = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getQuantity()#">,
				"hash" =
					<cfif NOT IsNull( arguments.quotationItem.getHash() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getHash()#">
					<cfelse>
						NULL
					</cfif>
				<cfif IsInstanceOf( arguments.quotationItem, "com.apirone.core.model.bean.QuotationItemSignage" )>
					,
					char_count             = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getSignageConfigItem().getCharCount()#">,
					height                 = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getSignageConfigItem().getHeight()#">,
					height_in_pixel        = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getSignageConfigItem().getHeightInPixel()#">,
					row_count              = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getSignageConfigItem().getRowCount()#">,
					signage_config_item_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getSignageConfigItem().getId()#">
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
