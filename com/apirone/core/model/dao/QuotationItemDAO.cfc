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
		<cfargument name="orderBy" type="String" required="true" default="quotation_items.ordinamento, quotation_items.quotation_item_id">
		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_item_id::varchar,
				quotation_items.quotation_id::varchar,
				quotation_zone_positions.quotation_zone_id::varchar,
				COUNT(quotation_item_id) OVER() AS total
			FROM quotation_items
					LEFT JOIN quotation_zone_positions ON quotation_items.quotation_zone_position_id = quotation_zone_positions.quotation_zone_position_id

				<cfif !IsNull( arguments.typeId )>
					<cfif arguments.typeId EQ "ART">
						INNER JOIN articles ON quotation_items.article_id = articles.article_id
					<cfelse>
						INNER JOIN products ON quotation_items.product_id = products.product_id
						INNER JOIN catalog_bundles ON catalog_bundles.catalog_bundle_id = products.catalog_bundle_id
						INNER JOIN product_categories ON catalog_bundles.product_category_id = product_categories.product_category_id
					</cfif>
				</cfif>
			WHERE 1=1

				<cfif !IsNull( arguments.quotationId )>
					AND quotation_items.quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.quotationZoneId )>
					AND quotation_items.quotation_zone_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationZoneId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.typeId )>
					<cfif arguments.typeId EQ "ART">
						AND quotation_items.article_id IS NOT NULL
					<cfelse>
						AND product_categories.product_category_type_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.typeId#">
					</cfif>
				</cfif>
			ORDER BY
				#super.sanitizeSQL( arguments.orderBy )#
				<!--- quotation_zone_positions.code ---->

				<cfif arguments.limit GT 0>
					LIMIT <cfqueryparam value="#arguments.limit#" cfsqltype="integer">
					OFFSET <cfqueryparam value="#arguments.offset#" cfsqltype="integer">
				</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="getMaxOrdinamento" returntype="Numeric">
		<cfargument name="quotationId" type="String" required="true">
		<cfargument name="typeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT COALESCE(MAX(quotation_items.ordinamento), 0) AS max_ord
			FROM quotation_items
			<cfif arguments.typeId EQ "ART">
				WHERE quotation_items.quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationId#">::uuid
				  AND quotation_items.article_id IS NOT NULL
			<cfelse>
				INNER JOIN products ON quotation_items.product_id = products.product_id
				INNER JOIN catalog_bundles ON catalog_bundles.catalog_bundle_id = products.catalog_bundle_id
				INNER JOIN product_categories ON catalog_bundles.product_category_id = product_categories.product_category_id
				WHERE quotation_items.quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationId#">::uuid
				  AND product_categories.product_category_type_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.typeId#">
			</cfif>
		</cfquery>
		<cfreturn Val(local.q.max_ord)>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="quotationItem" type="com.apirone.core.model.bean.QuotationItem" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_items (
				special,
				custom_image,
				status_id,
				quotation_id,
				quotation_zone_id,
				product_id,
				article_id,
				note,
				quantity,
				quotation_zone_position_id,
				"hash",
				ordinamento
				<cfif IsInstanceOf( arguments.quotationItem, "com.apirone.core.model.bean.QuotationItemPlate" )>
					,
					orientation_id,
					block_orientations
				</cfif>
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
				<cfqueryparam cfsqltype="Boolean" value="#arguments.quotationItem.getCustomImage()#">,
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
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getNote()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getQuantity()#">,
				<cfif NOT IsNull( arguments.quotationItem.getPosition() )>
					<cfqueryparam cfsqltype="Integer" value="#arguments.quotationItem.getPosition().getId()#">
				<cfelse>
					NULL
				</cfif>,
				<cfif NOT IsNull( arguments.quotationItem.getHash() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getHash()#">
				<cfelse>
					NULL
				</cfif>,
				<cfqueryparam cfsqltype="Integer" value="#arguments.quotationItem.getOrdinamento()#">
				<cfif IsInstanceOf( arguments.quotationItem, "com.apirone.core.model.bean.QuotationItemPlate" )>
					,
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getFrame().getOrientation().getId()#">,
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getBlockOrientations() ?: ''#" null="#IsNull( arguments.quotationItem.getBlockOrientations() ) || !Len( arguments.quotationItem.getBlockOrientations() )#">
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
				custom_image = <cfqueryparam cfsqltype="Boolean" value="#arguments.quotationItem.getCustomImage()#">,
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getStatus().getId()#">,
				quotation_zone_id =
					<cfif NOT IsNull( arguments.quotationItem.getQuotationZone() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getQuotationZone().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>,
				quotation_zone_position_id =
					<cfif NOT IsNull( arguments.quotationItem.getPosition() )>
						<cfqueryparam cfsqltype="Integer" value="#arguments.quotationItem.getPosition().getId()#">
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
				note = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getNote()#">,
				<!---- price = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getPrice()#">, ---->
				quantity = <cfqueryparam cfsqltype="Numeric" value="#arguments.quotationItem.getQuantity()#">,
				"hash" =
					<cfif NOT IsNull( arguments.quotationItem.getHash() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getHash()#">
					<cfelse>
						NULL
					</cfif>
				<cfif IsInstanceOf( arguments.quotationItem, "com.apirone.core.model.bean.QuotationItemPlate" )>
					,
					orientation_id         = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getFrame().getOrientation().getId()#">,
					block_orientations     = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItem.getBlockOrientations() ?: ''#" null="#IsNull( arguments.quotationItem.getBlockOrientations() ) || !Len( arguments.quotationItem.getBlockOrientations() )#">
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

	<cffunction name="updateOrdinamento" returntype="void">
		<cfargument name="quotationItemId" type="String" required="true">
		<cfargument name="ordinamento" type="Numeric" required="true">
		<cfquery datasource="apirone">
			UPDATE quotation_items
			SET ordinamento = <cfqueryparam cfsqltype="Integer" value="#arguments.ordinamento#">
			WHERE quotation_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemId#">::uuid
		</cfquery>
	</cffunction>

	<cffunction name="updateHash" returntype="Boolean">
		<cfargument name="quotationItemId" type="String" required="true">
		<cfargument name="hash" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			UPDATE quotation_items
			SET
				"hash" = <cfqueryparam cfsqltype="Varchar" value="#arguments.hash#">
			WHERE
				quotation_item_id = <cfqueryparam cfsqltype="Other" value="#arguments.quotationItemId#">::uuid
		</cfquery>
		<cfreturn true>
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

	<cffunction name="getQuantitaTotaleAltreRigheByQuotationLineIdAndFinishId" returntype="Numeric">
		<cfargument name="quotationId" type="String" required="true">
		<cfargument name="quotationItemId" type="String" required="true">
		<cfargument name="lineId" type="String" required="true">
		<cfargument name="finishId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				SUM(
					COALESCE(quotation_items.quantity, 0) * COALESCE(qz.quantity, 1) * COALESCE(qzo.quantity, 1)
				) AS total_quantity
			FROM quotation_items
				LEFT JOIN products ON quotation_items.product_id = products.product_id
				LEFT JOIN quotation_zones qz ON qz.quotation_zone_id = quotation_items.quotation_zone_id
				LEFT JOIN quotation_zones qzo ON qzo.quotation_zone_id = qz.origin_id
			WHERE
				products.line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid AND
				products.finish_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.finishId#">::uuid AND
				quotation_items.quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationId#">::uuid

				<cfif arguments.quotationItemId != "" >
					AND quotation_items.quotation_item_id <> <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemId#">::uuid
				</cfif>

		</cfquery>
		<cfreturn local.q.total_quantity ?: 0>
	</cffunction>

	<cffunction name="getQuantitaTotaleAltreRigheByQuotationAndProduct" returntype="Numeric">
		<cfargument name="quotationId" type="String" required="true">
		<cfargument name="quotationItemId" type="String" required="true">
		<cfargument name="productId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				SUM(
					COALESCE(quotation_items.quantity, 0) * COALESCE(qz.quantity, 1) * COALESCE(qzo.quantity, 1)
				) AS total_quantity
			FROM quotation_items
				LEFT JOIN products ON quotation_items.product_id = products.product_id
				LEFT JOIN quotation_zones qz ON qz.quotation_zone_id = quotation_items.quotation_zone_id
				LEFT JOIN quotation_zones qzo ON qzo.quotation_zone_id = qz.origin_id
			WHERE
				products.product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid AND
				quotation_items.quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationId#">::uuid
				<cfif arguments.quotationItemId != "" >
					AND quotation_items.quotation_item_id <> <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemId#">::uuid
				</cfif>

		</cfquery>
		<cfreturn local.q.total_quantity ?: 0>
	</cffunction>

	<cffunction name="getAltreRigheByQuotationLineIdAndFinishId" returntype="Query">
		<cfargument name="quotationId" type="String" required="true">
		<cfargument name="quotationItemId" type="String" required="true">
		<cfargument name="lineId" type="String" required="true">
		<cfargument name="finishId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_items.*
			FROM quotation_items
			LEFT JOIN products ON quotation_items.product_id = products.product_id
			WHERE
				products.line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid AND
				products.finish_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.finishId#">::uuid AND
				quotation_items.quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationId#">::uuid AND
				quotation_items.quotation_item_id <> <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemId#">::uuid
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="getAltreRigheByQuotationAndProductId" returntype="Query">
		<cfargument name="quotationId" type="String" required="true">
		<cfargument name="quotationItemId" type="String" required="true">
		<cfargument name="productId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_items.*
			FROM quotation_items
			LEFT JOIN products ON quotation_items.product_id = products.product_id
			WHERE
				products.product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid AND
				quotation_items.quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationId#">::uuid AND
				quotation_items.quotation_item_id <> <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemId#">::uuid
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<!---
		Recupera in batch più righe di preventivo dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query" access="public">
		<cfargument name="ids" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.ids )>

		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_item_id::varchar,
				quotation_id::varchar,
				quotation_zone_id::varchar,
				*
			FROM quotation_items
			WHERE quotation_item_id = ANY(
				ARRAY[<cfqueryparam value="#idsList#" list="true" cfsqltype="varchar">]::uuid[]
			)
		</cfquery>

		<cfreturn local.q>
	</cffunction>

</cfcomponent>
