<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<!---
		Righe di preventivo che usano gli elementi di catalogo indicati, raggruppate
		per preventivo / zona / tipo, con lo stato corrente del preventivo.
		Un prodotto è usato come prodotto della riga, come frutto, nei prezzi; un
		attributo / valore attraverso le righe attributo-valore ( product_items ) dei
		prodotti, compreso tutto il sotto-albero ( origin_id ) di quelle indicate.
		Contano tutte le versioni di un preventivo.
	--->
	<cffunction name="findQuotationUsage" returntype="Query" access="public">
		<cfargument name="productIds" type="Array" default="#[]#">
		<cfargument name="productItemIds" type="Array" default="#[]#">
		<cfargument name="attributeIds" type="Array" default="#[]#">
		<cfargument name="attributeValueIds" type="Array" default="#[]#">
		<cfargument name="rawValueIds" type="Array" default="#[]#">

		<cfset var hasProducts = ArrayLen( arguments.productIds ) GT 0>

		<cfquery name="local.q" datasource="apirone">
			WITH RECURSIVE seed AS (
				SELECT pi.product_item_id
				FROM product_items pi
				WHERE false
				<cfif hasProducts>
					OR pi.product_id = ANY( ARRAY[<cfqueryparam value="#ArrayToList( arguments.productIds )#" list="true" cfsqltype="varchar">]::uuid[] )
				</cfif>
				<cfif ArrayLen( arguments.productItemIds )>
					OR pi.product_item_id IN ( <cfqueryparam value="#ArrayToList( arguments.productItemIds )#" list="true" cfsqltype="integer"> )
				</cfif>
				<cfif ArrayLen( arguments.rawValueIds )>
					OR pi.raw_value_id IN ( <cfqueryparam value="#ArrayToList( arguments.rawValueIds )#" list="true" cfsqltype="integer"> )
				</cfif>
				<cfif ArrayLen( arguments.attributeIds ) OR ArrayLen( arguments.attributeValueIds ) OR ArrayLen( arguments.rawValueIds )>
					OR pi.attribute_raw_value_id IN (
						SELECT arv.attribute_raw_value_id
						FROM attributes_raw_values arv
						WHERE false
						<cfif ArrayLen( arguments.attributeIds )>
							OR arv.attribute_id = ANY( ARRAY[<cfqueryparam value="#ArrayToList( arguments.attributeIds )#" list="true" cfsqltype="varchar">]::uuid[] )
						</cfif>
						<cfif ArrayLen( arguments.attributeValueIds )>
							OR arv.attribute_raw_value_id IN ( <cfqueryparam value="#ArrayToList( arguments.attributeValueIds )#" list="true" cfsqltype="integer"> )
						</cfif>
						<cfif ArrayLen( arguments.rawValueIds )>
							OR arv.raw_value_id IN ( <cfqueryparam value="#ArrayToList( arguments.rawValueIds )#" list="true" cfsqltype="integer"> )
						</cfif>
					)
				</cfif>
			),
			tree AS (
				SELECT product_item_id FROM seed
				UNION
				SELECT pi.product_item_id FROM product_items pi
				JOIN tree t ON pi.origin_id = t.product_item_id
			),
			used AS (
				SELECT COALESCE( qipi.quotation_item_id, qif.quotation_item_id ) AS quotation_item_id
				FROM quotation_item_product_items qipi
				LEFT JOIN quotation_item_fruits qif ON qif.quotation_item_fruit_id = qipi.quotation_item_fruit_id
				WHERE qipi.product_item_id IN ( SELECT product_item_id FROM tree )
				   OR qipi.origin_id IN ( SELECT product_item_id FROM tree )
				<cfif hasProducts>
					UNION
					SELECT qi.quotation_item_id
					FROM quotation_items qi
					WHERE qi.product_id = ANY( ARRAY[<cfqueryparam value="#ArrayToList( arguments.productIds )#" list="true" cfsqltype="varchar">]::uuid[] )
					   OR qi.product_origin_id = ANY( ARRAY[<cfqueryparam value="#ArrayToList( arguments.productIds )#" list="true" cfsqltype="varchar">]::uuid[] )
					UNION
					SELECT qif.quotation_item_id
					FROM quotation_item_fruits qif
					WHERE qif.fruit_id = ANY( ARRAY[<cfqueryparam value="#ArrayToList( arguments.productIds )#" list="true" cfsqltype="varchar">]::uuid[] )
					UNION
					SELECT qip.quotation_item_id
					FROM quotation_item_prices qip
					WHERE qip.product_id = ANY( ARRAY[<cfqueryparam value="#ArrayToList( arguments.productIds )#" list="true" cfsqltype="varchar">]::uuid[] )
					UNION
					SELECT qip.quotation_item_id
					FROM quotation_item_price_lines qipl
					JOIN quotation_item_prices qip ON qip.quotation_item_price_id = qipl.quotation_item_price_id
					WHERE qipl.product_id = ANY( ARRAY[<cfqueryparam value="#ArrayToList( arguments.productIds )#" list="true" cfsqltype="varchar">]::uuid[] )
				</cfif>
			)
			SELECT
				q.quotation_id::varchar AS quotation_id,
				q.quotation_number,
				q.version_number,
				COALESCE( h.status_id, '' ) AS status_id,
				qi.quotation_zone_id::varchar AS zone_id,
				z.quotation_zone,
				CASE WHEN qi.article_id IS NOT NULL THEN 'ART' ELSE pc.product_category_type_id END AS type_id,
				COUNT( DISTINCT qi.quotation_item_id ) AS item_count,
				STRING_AGG( DISTINCT qi.quotation_item_id::varchar, ',' ) AS item_ids
			FROM used u
			JOIN quotation_items qi ON qi.quotation_item_id = u.quotation_item_id
			JOIN quotations q ON q.quotation_id = qi.quotation_id
			LEFT JOIN quotation_status_history h ON h.quotation_status_history_id = q.quotation_status_history_id
			LEFT JOIN quotation_zones z ON z.quotation_zone_id = qi.quotation_zone_id
			LEFT JOIN products p ON p.product_id = qi.product_id
			LEFT JOIN catalog_bundles cb ON cb.catalog_bundle_id = p.catalog_bundle_id
			LEFT JOIN product_categories pc ON pc.product_category_id = cb.product_category_id
			GROUP BY q.quotation_id, q.quotation_number, q.version_number, h.status_id, qi.quotation_zone_id, z.quotation_zone, 7
			ORDER BY q.quotation_number, q.version_number, z.quotation_zone, 7
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Eliminazione logica: le righe restano per i preventivi che le usano.
		Le righe attributo-valore si eliminano con tutto il sotto-albero ( origin_id ).
	--->
	<cffunction name="softDelete" returntype="void" access="public">
		<cfargument name="productIds" type="Array" default="#[]#">
		<cfargument name="productItemIds" type="Array" default="#[]#">
		<cfargument name="attributeIds" type="Array" default="#[]#">
		<cfargument name="attributeValueIds" type="Array" default="#[]#">
		<cfargument name="rawValueIds" type="Array" default="#[]#">

		<cfif ArrayLen( arguments.productIds )>
			<cfquery datasource="apirone">
				UPDATE products SET deleted_at = NOW()
				WHERE product_id = ANY( ARRAY[<cfqueryparam value="#ArrayToList( arguments.productIds )#" list="true" cfsqltype="varchar">]::uuid[] )
					AND deleted_at IS NULL
			</cfquery>
		</cfif>

		<cfif ArrayLen( arguments.productItemIds )>
			<cfquery datasource="apirone">
				WITH RECURSIVE tree AS (
					SELECT product_item_id FROM product_items
					WHERE product_item_id IN ( <cfqueryparam value="#ArrayToList( arguments.productItemIds )#" list="true" cfsqltype="integer"> )
					UNION
					SELECT pi.product_item_id FROM product_items pi
					JOIN tree t ON pi.origin_id = t.product_item_id
				)
				UPDATE product_items SET deleted_at = NOW()
				WHERE product_item_id IN ( SELECT product_item_id FROM tree )
					AND deleted_at IS NULL
			</cfquery>
		</cfif>

		<cfif ArrayLen( arguments.attributeIds )>
			<cfquery datasource="apirone">
				UPDATE attributes SET deleted_at = NOW()
				WHERE attribute_id = ANY( ARRAY[<cfqueryparam value="#ArrayToList( arguments.attributeIds )#" list="true" cfsqltype="varchar">]::uuid[] )
					AND deleted_at IS NULL
			</cfquery>
		</cfif>

		<cfif ArrayLen( arguments.attributeValueIds )>
			<cfquery datasource="apirone">
				UPDATE attributes_raw_values SET deleted_at = NOW()
				WHERE attribute_raw_value_id IN ( <cfqueryparam value="#ArrayToList( arguments.attributeValueIds )#" list="true" cfsqltype="integer"> )
					AND deleted_at IS NULL
			</cfquery>
		</cfif>

		<cfif ArrayLen( arguments.rawValueIds )>
			<cfquery datasource="apirone">
				UPDATE raw_values SET deleted_at = NOW()
				WHERE raw_value_id IN ( <cfqueryparam value="#ArrayToList( arguments.rawValueIds )#" list="true" cfsqltype="integer"> )
					AND deleted_at IS NULL
			</cfquery>
		</cfif>
	</cffunction>

	<!---
		Righe di un preventivo ( o una sola riga ) che usano elementi eliminati dal
		catalogo: il prodotto, un frutto o una scelta attributo / valore. label: cosa
		non è più a catalogo, per l'avviso all'utente.
	--->
	<cffunction name="findDeletedInQuotation" returntype="Query" access="public">
		<cfargument name="quotationId" type="String">
		<cfargument name="quotationItemId" type="String">

		<cfquery name="local.q" datasource="apirone">
			WITH items AS (
				SELECT qi.quotation_item_id, qi.product_id
				FROM quotation_items qi
				WHERE
				<cfif !IsNull( arguments.quotationItemId )>
					qi.quotation_item_id = <cfqueryparam value="#arguments.quotationItemId#" cfsqltype="varchar">::uuid
				<cfelse>
					qi.quotation_id = <cfqueryparam value="#arguments.quotationId#" cfsqltype="varchar">::uuid
				</cfif>
			),
			product_labels AS (
				SELECT
					p.product_id,
					COALESCE(
						( SELECT t.text FROM texts t WHERE t.product_id = p.product_id AND t.lang_id = 'IT' AND t.text_kind_id = 'NAME' LIMIT 1 ),
						NULLIF( p.code, '' ),
						NULLIF( CONCAT_WS( ' ', l.code, m.code, f.code ), '' ),
						'prodotto'
					) AS label
				FROM products p
				LEFT JOIN catalog_bundles cb ON cb.catalog_bundle_id = p.catalog_bundle_id
				LEFT JOIN lines l ON l.line_id = cb.line_id
				LEFT JOIN models m ON m.model_id = cb.model_id
				LEFT JOIN finishes f ON f.finish_id = p.finish_id
				WHERE p.deleted_at IS NOT NULL
			)
			SELECT i.quotation_item_id::varchar AS quotation_item_id, pl.label
			FROM items i
			JOIN product_labels pl ON pl.product_id = i.product_id

			UNION

			SELECT qif.quotation_item_id::varchar, 'frutto ' || pl.label
			FROM quotation_item_fruits qif
			JOIN items i ON i.quotation_item_id = qif.quotation_item_id
			JOIN product_labels pl ON pl.product_id = qif.fruit_id

			UNION

			SELECT
				COALESCE( qipi.quotation_item_id, qif.quotation_item_id )::varchar,
				COALESCE( ( SELECT t.text FROM texts t WHERE t.attribute_id = a.attribute_id AND t.lang_id = 'IT' AND t.text_kind_id = 'NAME' LIMIT 1 ), a.code, 'attributo' )
					|| ': '
					|| COALESCE( ( SELECT t.text FROM texts t WHERE t.raw_value_id = rv.raw_value_id AND t.lang_id = 'IT' AND t.text_kind_id = 'NAME' LIMIT 1 ), rv.code, 'valore' )
			FROM quotation_item_product_items qipi
			LEFT JOIN quotation_item_fruits qif ON qif.quotation_item_fruit_id = qipi.quotation_item_fruit_id
			JOIN items i ON i.quotation_item_id = COALESCE( qipi.quotation_item_id, qif.quotation_item_id )
			JOIN product_items pi ON pi.product_item_id = qipi.product_item_id
			JOIN attributes_raw_values arv ON arv.attribute_raw_value_id = pi.attribute_raw_value_id
			JOIN attributes a ON a.attribute_id = arv.attribute_id
			LEFT JOIN raw_values rv ON rv.raw_value_id = arv.raw_value_id
			WHERE pi.deleted_at IS NOT NULL
				OR arv.deleted_at IS NOT NULL
				OR a.deleted_at IS NOT NULL
				OR rv.deleted_at IS NOT NULL

			ORDER BY 1, 2
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="readQuotationItemProductId" returntype="String" access="public">
		<cfargument name="quotationItemId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT product_id::varchar AS product_id
			FROM quotation_items
			WHERE quotation_item_id = <cfqueryparam value="#arguments.quotationItemId#" cfsqltype="varchar">::uuid
		</cfquery>

		<cfreturn local.q.recordCount && !IsNull( local.q.product_id[ 1 ] ) ? local.q.product_id[ 1 ] : "">
	</cffunction>

	<cffunction name="restoreProduct" returntype="void" access="public">
		<cfargument name="productId" type="String" required="true">

		<cfquery datasource="apirone">
			UPDATE products SET deleted_at = NULL
			WHERE product_id = <cfqueryparam value="#arguments.productId#" cfsqltype="varchar">::uuid
		</cfquery>
	</cffunction>

</cfcomponent>
