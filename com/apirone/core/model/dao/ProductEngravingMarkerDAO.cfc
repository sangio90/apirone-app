<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read" returntype="Query">
		<cfargument name="productEngravingMarkerId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT product_id::varchar, attribute_id::varchar, *
			FROM product_engraving_markers
			WHERE product_engraving_marker_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productEngravingMarkerId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="readByIds" returntype="Query" access="public">
		<cfargument name="ids" type="Array" required="true">

		<cfreturn super.$readByIdsInteger(
			table    = "product_engraving_markers",
			pkColumn = "product_engraving_marker_id",
			ids      = arguments.ids
		)>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="productId" type="String">
		<cfargument name="attributeId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="order">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				product_engraving_marker_id::varchar,
				COUNT(product_engraving_marker_id) OVER() AS total
			FROM product_engraving_markers
			WHERE 1=1
				<cfif !IsNull( arguments.productId ) AND Len( arguments.productId )>
					AND product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
				</cfif>
				<cfif !IsNull( arguments.attributeId ) AND Len( arguments.attributeId )>
					AND attribute_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attributeId#">::uuid
				</cfif>
			ORDER BY attribute_id, "order"

			<cfif arguments.limit GT 0>
				LIMIT <cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET <cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!--- Tutti i marker di più frutti in una query (modale placca). --->
	<cffunction name="readByProductIds" returntype="Query" access="public">
		<cfargument name="productIds" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.productIds )>

		<cfquery name="local.q" datasource="apirone">
			SELECT product_id::varchar, attribute_id::varchar, *
			FROM product_engraving_markers
			WHERE product_id = ANY(
				ARRAY[<cfqueryparam value="#idsList#" list="true" cfsqltype="varchar">]::uuid[]
			)
			ORDER BY product_id, attribute_id, "order"
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Attributi radice dell'incisione presenti fra i product item di un frutto
		(quelli con codice nella lista data), con il nome nella lingua richiesta.
	--->
	<cffunction name="findEngravingAttributes" returntype="Query" access="public">
		<cfargument name="productId" type="String" required="true">
		<cfargument name="codes" type="Array" required="true">
		<cfargument name="langId" type="String" required="true" default="IT">

		<cfquery name="local.q" datasource="apirone">
			SELECT DISTINCT
				a.attribute_id::varchar AS attribute_id,
				a.code,
				t.text AS name
			FROM product_items pi
				INNER JOIN attributes_raw_values arv USING ( attribute_raw_value_id )
				INNER JOIN attributes a USING ( attribute_id )
				LEFT JOIN texts t ON t.attribute_id = a.attribute_id
					AND t.lang_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.langId#">
					AND t.text_kind_id = 'NAME'
				<!--- attributo del product item padre: se e' a sua volta un attributo radice
				      (es. IL sotto IS/II) la griglia e' del padre, non di questo --->
				LEFT JOIN product_items pio ON pio.product_item_id = pi.origin_id
				LEFT JOIN attributes_raw_values arvo ON arvo.attribute_raw_value_id = pio.attribute_raw_value_id
				LEFT JOIN attributes ao ON ao.attribute_id = arvo.attribute_id
			WHERE pi.product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
				AND a.code IN ( <cfqueryparam cfsqltype="Varchar" value="#ArrayToList( arguments.codes )#" list="true"> )
				AND (
					pi.origin_id IS NULL
					OR ao.code IS NULL
					OR ao.code NOT IN ( <cfqueryparam cfsqltype="Varchar" value="#ArrayToList( arguments.codes )#" list="true"> )
				)
			ORDER BY a.code
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Immagini orizzontali candidate come base del disegno del frutto: prima quella del
		prodotto, poi quelle dei suoi product item (molti frutti hanno solo queste).
	--->
	<cffunction name="findBaseImages" returntype="Query" access="public">
		<cfargument name="productId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT f.file_id, f.width, f.height, 1 AS priority, 0 AS item_level, 0 AS item_order
			FROM files f
			WHERE f.product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
				AND f.type_id = 'horizontal'
				AND f.deleted_at IS NULL
			UNION ALL
			<!--- item di primo livello prima (es. la forma del pulsante), poi gli altri (overlay) --->
			SELECT f.file_id, f.width, f.height, 2 AS priority,
				CASE WHEN pi.origin_id IS NULL THEN 0 ELSE 1 END AS item_level,
				COALESCE( pi.orderby, 0 ) AS item_order
			FROM files f
				INNER JOIN product_items pi ON pi.product_item_id = f.product_item_id
			WHERE pi.product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
				AND f.type_id = 'horizontal'
				AND f.deleted_at IS NULL
			ORDER BY priority, item_level, item_order, width DESC
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="marker" type="com.apirone.core.model.bean.ProductEngravingMarker" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO product_engraving_markers (
				product_id,
				attribute_id,
				"order",
				x_px,
				y_px,
				x_mm,
				y_mm
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.marker.getProductId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.marker.getAttributeId()#">::uuid,
				<cfqueryparam cfsqltype="Integer" value="#arguments.marker.getOrder()#">,
				<cfqueryparam cfsqltype="Decimal" scale="2" value="#arguments.marker.getXPx()#">,
				<cfqueryparam cfsqltype="Decimal" scale="2" value="#arguments.marker.getYPx()#">,
				<cfqueryparam cfsqltype="Decimal" scale="2" value="#arguments.marker.getXMm()#">,
				<cfqueryparam cfsqltype="Decimal" scale="2" value="#arguments.marker.getYMm()#">
			) RETURNING product_engraving_marker_id
		</cfquery>

		<cfreturn local.q.product_engraving_marker_id.toString()>
	</cffunction>

	<!--- Aggiorna coordinate e numero di un marker esistente: si usa al salvataggio della
	      griglia per non cambiare gli id delle posizioni già usate nei preventivi. --->
	<cffunction name="update" returntype="Boolean">
		<cfargument name="marker" type="com.apirone.core.model.bean.ProductEngravingMarker" required="true">

		<cfquery datasource="apirone">
			UPDATE product_engraving_markers
			SET "order" = <cfqueryparam cfsqltype="Integer" value="#arguments.marker.getOrder()#">,
				x_px = <cfqueryparam cfsqltype="Decimal" scale="2" value="#arguments.marker.getXPx()#">,
				y_px = <cfqueryparam cfsqltype="Decimal" scale="2" value="#arguments.marker.getYPx()#">,
				x_mm = <cfqueryparam cfsqltype="Decimal" scale="2" value="#arguments.marker.getXMm()#">,
				y_mm = <cfqueryparam cfsqltype="Decimal" scale="2" value="#arguments.marker.getYMm()#">
			WHERE product_engraving_marker_id = <cfqueryparam cfsqltype="Integer" value="#arguments.marker.getId()#">
		</cfquery>

		<cfreturn true>
	</cffunction>

	<!--- Elimina i marker in eccesso quando la griglia viene salvata con meno posizioni. --->
	<cffunction name="deleteByProductAttributeFromOrder" returntype="Boolean">
		<cfargument name="productId" type="String" required="true">
		<cfargument name="attributeId" type="String" required="true">
		<cfargument name="fromOrder" type="Numeric" required="true">

		<cfquery datasource="apirone">
			DELETE FROM product_engraving_markers
			WHERE product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
				AND attribute_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attributeId#">::uuid
				AND "order" >= <cfqueryparam cfsqltype="Integer" value="#arguments.fromOrder#">
		</cfquery>

		<cfreturn true>
	</cffunction>

	<cffunction name="deleteByProductAttribute" returntype="Boolean">
		<cfargument name="productId" type="String" required="true">
		<cfargument name="attributeId" type="String" required="true">

		<cfquery datasource="apirone">
			DELETE FROM product_engraving_markers
			WHERE product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
				AND attribute_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attributeId#">::uuid
		</cfquery>

		<cfreturn true>
	</cffunction>

</cfcomponent>
