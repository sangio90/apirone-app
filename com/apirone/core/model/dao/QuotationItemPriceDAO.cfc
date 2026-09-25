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

	<!---
		Recupera in batch più QuotationItemPrice dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query" access="public">
		<cfargument name="ids" type="Array" required="true">

		<cfreturn super.$readByIdsInteger(
			table   = "quotation_item_prices",
			pkColumn = "quotation_item_price_id",
			ids     = arguments.ids
		)>
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
				price_method_id,
				missing_price
			) VALUES (
				<!--- <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemPrice.getProductId()#">::uuid, --->
				'',
				<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemPrice.getAmount()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemPrice.getQuotationItemId()#">::uuid,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemPrice.getDiscount1()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItemPrice.getDiscount2()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemPrice.getMethod().getId()#">,
				<cfqueryparam cfsqltype="Boolean" value="#arguments.quotationItemPrice.getMissingPrice()#">
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
				price_method_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemPrice.getMethod().getId()#">,
				missing_price = <cfqueryparam cfsqltype="Boolean" value="#arguments.quotationItemPrice.getMissingPrice()#">
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

	<!---
		Applica lo stesso sconto a tutte le righe di un preventivo di una famiglia
		(PLA, ACC, SEG, ART), in tutte le zone. Lo sconto sovrascrive quelli esistenti:
		discount1 = sconto, discount2 = 0. Le righe a prezzo fisso (F) sono escluse
		perché il loro totale non considera gli sconti.
		Restituisce { updated, skippedFixed }.
	--->
	<cffunction name="applyDiscountByQuotationAndType" returntype="Struct" access="public">
		<cfargument name="quotationId" type="String" required="true">
		<cfargument name="typeId" type="String" required="true">
		<cfargument name="discount" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			WITH family_items AS (
				SELECT quotation_items.quotation_item_id
				FROM quotation_items
				<cfif arguments.typeId EQ "ART">
					WHERE quotation_items.article_id IS NOT NULL
				<cfelse>
					INNER JOIN products ON quotation_items.product_id = products.product_id
					INNER JOIN catalog_bundles ON catalog_bundles.catalog_bundle_id = products.catalog_bundle_id
					INNER JOIN product_categories ON catalog_bundles.product_category_id = product_categories.product_category_id
					WHERE product_categories.product_category_type_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.typeId#">
				</cfif>
					AND quotation_items.quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationId#">::uuid
			),
			updated AS (
				UPDATE quotation_item_prices
				SET
					discount1 = <cfqueryparam cfsqltype="Numeric" scale="2" value="#arguments.discount#">,
					discount2 = 0
				WHERE quotation_item_id IN ( SELECT quotation_item_id FROM family_items )
					AND price_method_id IS DISTINCT FROM 'F'
				RETURNING quotation_item_price_id
			)
			SELECT
				( SELECT COUNT(*) FROM updated ) AS updated_count,
				( SELECT COUNT(*)
				  FROM quotation_item_prices
				  WHERE quotation_item_id IN ( SELECT quotation_item_id FROM family_items )
					AND price_method_id = 'F' ) AS skipped_fixed_count
		</cfquery>

		<cfreturn {
			"updated"      = Val( local.q.updated_count ),
			"skippedFixed" = Val( local.q.skipped_fixed_count )
		}>
	</cffunction>

	<!---
		Recupera in batch i prezzi collegati a più quotation_item_id.
		Utilizzato da QuotationItemService.getMany() per evitare N+1.
	--->
	<cffunction name="readByQuotationItemIds" returntype="Query" access="public">
		<cfargument name="quotationItemIds" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.quotationItemIds )>

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM quotation_item_prices
			WHERE quotation_item_id = ANY(
				ARRAY[<cfqueryparam value="#idsList#" list="true" cfsqltype="varchar">]::uuid[]
			)
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Righe del preventivo salvate senza prezzo configurato (missing_price), raggruppate
		per tipo di categoria (PLA/SEG/ACC): usato dall'avviso nella pagina del preventivo.
	--->
	<cffunction name="countMissingPriceByQuotationId" returntype="Query" access="public">
		<cfargument name="quotationId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				product_categories.product_category_type_id AS type_id,
				COUNT(*) AS items
			FROM quotation_items
				INNER JOIN quotation_item_prices ON quotation_item_prices.quotation_item_id = quotation_items.quotation_item_id
				INNER JOIN products ON products.product_id = quotation_items.product_id
				INNER JOIN catalog_bundles ON catalog_bundles.catalog_bundle_id = products.catalog_bundle_id
				INNER JOIN product_categories ON product_categories.product_category_id = catalog_bundles.product_category_id
			WHERE quotation_items.quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationId#">::uuid
				AND quotation_item_prices.missing_price
			GROUP BY product_categories.product_category_type_id
		</cfquery>

		<cfreturn local.q>
	</cffunction>

</cfcomponent>
