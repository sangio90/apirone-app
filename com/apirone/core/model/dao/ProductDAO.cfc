<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="productId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				product_id::varchar,
				model_id::varchar,
				line_id::varchar,
				finish_id::varchar,
				catalog_bundle_id::varchar,
				attributes_important::varchar,
				*
			FROM
				products
			WHERE
				product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="readIds">
		<cfquery name="local.q" datasource="apirone">
			SELECT
				product_id::varchar
			FROM
				products
				INNER JOIN product_categories 
					ON products.product_category_id = product_categories.product_category_id
			WHERE
				product_categories.product_category_type_id IN ('ACC', 'SEG')
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="readByCode" output="false">
		<cfargument name="code" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				product_id::varchar,
				*
			FROM
				products
			WHERE
				code = <cfqueryparam cfsqltype="varchar" value="#arguments.code#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="lineId" type="String">
		<cfargument name="modelId" type="String">
		<cfargument name="finishId" type="String">
		<cfargument name="excludedIds" type="Array">
		<cfargument name="categoryId" type="Numeric">
		<cfargument name="catalogBundleId" type="String">
		<cfargument name="categoryModeId" type="String">
		<cfargument name="str" type="String">

		<cfargument name="orderby" required="true" type="String" default="product.product_id">
		<cfargument name="limit" required="true" type="Numeric" default="15">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT DISTINCT
				--products.product_id,
				products.product_id::varchar,
				products.code,
				product_categories.code:: varchar,
				lines.code:: varchar,
				models.code::varchar,
				finishes.code::varchar,
				COUNT(product_id) OVER() AS total
			FROM
				products
					LEFT JOIN catalog_bundles USING ( catalog_bundle_id )
						INNER JOIN product_categories
							ON (
								(products.catalog_bundle_id IS NULL AND product_categories.product_category_id = products.product_category_id)
								OR (products.catalog_bundle_id IS NOT NULL AND product_categories.product_category_id = catalog_bundles.product_category_id)
						)
						LEFT JOIN lines ON catalog_bundles.line_id = lines.line_id
						LEFT JOIN models ON catalog_bundles.model_id = models.model_id
						LEFT JOIN finishes ON products.finish_id = finishes.finish_id
						<cfif !IsNull( arguments.str )>
							INNER JOIN texts USING ( product_id )
						</cfif>

			WHERE 1=1

				<cfif !IsNull( arguments.str )>
					AND
					( 	texts.text ILIKE <cfqueryparam cfsqltype="varchar" value="%#arguments.str#%">
						OR products.code ILIKE <cfqueryparam cfsqltype="varchar" value="%#arguments.str#%">
					)
				</cfif>

				<cfif !IsNull( arguments.finishId )>
					AND products.finish_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.finishId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.catalogBundleId )>
					AND products.catalog_bundle_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.catalogBundleId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.modelId )>
					AND catalog_bundles.model_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.modelId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.lineId )>

					<cfif !IsNull( arguments.categoryModeId ) AND arguments.categoryModeId EQ "BAS">
						AND jsonb_exists_any( lines, ARRAY[<cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">] )
					<cfelse>
						AND catalog_bundles.line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
					</cfif>

				</cfif>

				<cfif !IsNull( arguments.categoryId )>
					AND (
						( products.catalog_bundle_id IS NULL AND products.product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.categoryId#">)
						OR (catalog_bundles.product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.categoryId#">)
					)
				</cfif>

				<cfif !IsNull( arguments.excludedCategoryIds ) AND ArrayLen( arguments.excludedCategoryIds )>
					AND (
						(products.catalog_bundle_id IS NULL AND products.product_category_id NOT IN (<cfqueryparam cfsqltype="Integer" value="#arguments.excludedCategoryIds#" list="yes">))
						OR (products.catalog_bundle_id IS NOT NULL AND catalog_bundles.product_category_id NOT IN (<cfqueryparam cfsqltype="Integer" value="#arguments.excludedCategoryIds#" list="yes">))
					)
				</cfif>

				<cfif !IsNull( arguments.categoryModeId )>
					AND product_categories.mode_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.categoryModeId#">
				</cfif>

			ORDER BY
				<!--- #super.sanitizeSQL( arguments.orderBy )# - --->
				<!--- TODO: dovrei fare la inner se l'ordinamento prevede product.name --->
				product_categories.code::varchar,
				lines.code::varchar,
				models.code::varchar,
				finishes.code::varchar,
				products.code

			<cfif arguments.limit GTE 0>
				LIMIT
					<cfqueryparam cfsqltype="integer" value="#arguments.limit#">
				OFFSET
					<cfqueryparam cfsqltype="integer" value="#arguments.offset#">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="product" type="com.apirone.core.model.bean.Product" required="true">

		<cfset var lines = super.getLinesAsArray( product.getLines() )>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO products (
				finish_id,
				code,
				position_count,
				catalog_bundle_id,
				product_category_id,
				status_id,
				lines
			)
			VALUES (
				<cfif !IsNull( arguments.product.getFinish() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.product?.getFinish()?.getId()#">::uuid
				<cfelse>
					NULL
				</cfif>
				,
				<cfif Len( arguments.product.getCode() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.product.getCode()#">
				<cfelse>
					NULL
				</cfif>
				,
				<cfif !IsNull( arguments.product.getPositionCount() )>
					<cfqueryparam cfsqltype="Integer" value="#arguments.product.getPositionCount()#">
				<cfelse>
					NULL
				</cfif>
				,
				<cfif !IsNull( arguments.product.getCatalogBundle() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.product?.getCatalogBundle()?.getId()#">::uuid
				<cfelse>
					NULL
				</cfif>
				,
				<cfif IsInstanceOf( arguments.product, "com.apirone.core.model.bean.ProductBase" )>
					<cfqueryparam cfsqltype="Integer" value="#arguments.product.getCategory().getId()#">
				<cfelse>
					NULL
				</cfif>
				,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.product.getStatus().getId()#">,
				<cfqueryparam cfsqltype="Other" value="#SerializeJSON( lines )#">
			) RETURNING product_id
		</cfquery>

		<cfreturn local.q.product_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="product" type="com.apirone.core.model.bean.Product" required="true">

		<cfset var lines = super.getLinesAsArray( product.getLines() )>

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				products
			SET
				model_id =
					<cfif !IsNull( arguments.product.getModel() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.product?.getModel()?.getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,

				line_id =
					<cfif !IsNull( arguments.product.getLine() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.product?.getLine()?.getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,

				catalog_bundle_id =
					<cfif !IsNull( arguments.product.getCatalogBundle() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.product?.getCatalogBundle()?.getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,

				finish_id =
					<cfif !IsNull( arguments.product.getFinish() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.product?.getFinish()?.getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,

				code =
					<cfif Len( arguments.product.getCode() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.product.getCode()#">
					<cfelse>
						NULL
					</cfif>
				,

				position_count =
					<cfif Val( arguments.product.getPositionCount() )>
						<cfqueryparam cfsqltype="Integer" value="#arguments.product.getPositionCount()#">
					<cfelse>
						NULL
					</cfif>
				,
				lines = <cfqueryparam cfsqltype="Other" value="#SerializeJSON( lines )#">,

				<cfif arguments.product.getPlateWidth()>
					plate_width = <cfqueryparam cfsqltype="Numeric" value="#arguments.product.getPlateWidth()#">,
				</cfif>

				<cfif arguments.product.getPlateHeight()>
					plate_height = <cfqueryparam cfsqltype="Numeric" value="#arguments.product.getPlateHeight()#">,
				</cfif>

				<cfif arguments.product.getMarginTop()>
					margin_top = <cfqueryparam cfsqltype="Numeric" value="#arguments.product.getMarginTop()#">,
				</cfif>

				<cfif arguments.product.getMarginLeft()>
					margin_left = <cfqueryparam cfsqltype="Numeric" value="#arguments.product.getMarginLeft()#">,
				</cfif>

				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.product.getStatus().getId()#">
			WHERE
				product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.product.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.product.getId()>
	</cffunction>

	<cffunction name="updateDetail" returntype="String">
		<cfargument name="product" type="com.apirone.core.model.bean.Product" required="true">

		<cfset var importantAttributes = super.getAttributesAsArray( arguments.product.getImportantAttributes() )>

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				products
			SET
				min_quantity =
					<cfif Val( arguments.product.getMinQuantity() )>
						<cfqueryparam cfsqltype="Integer" value="#arguments.product.getMinQuantity()#">
					<cfelse>
						NULL
					</cfif>
				,
				max_quantity =
					<cfif Val( arguments.product.getMaxQuantity() )>
						<cfqueryparam cfsqltype="Integer" value="#arguments.product.getMaxQuantity()#">
					<cfelse>
						NULL
					</cfif>
				,
				special = <cfqueryparam cfsqltype="Boolean" value="#arguments.product.getSpecial()#">,
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.product.getStatus().getId()#">,
				attributes_important = <cfqueryparam cfsqltype="Other" value="#SerializeJSON( importantAttributes )#">
			WHERE
				product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.product.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.product.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="productId" type="String">

		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM products
			WHERE
				product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
		</cfquery>

		<cfreturn true>
	</cffunction>

	<cffunction name="deleteAllByParams" returntype="Boolean">
		<cfargument name="lineId" type="String" required="true">
		<cfargument name="categoryId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM products
			WHERE
				 catalog_bundle_id IN (
					SELECT catalog_bundle_id
					FROM catalog_bundles
					WHERE
						product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.categoryId#"> AND
						line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
				)
			RETURNING product_id
		</cfquery>

		<cfreturn true>
	</cffunction>

	<!---
		Recupera in batch più prodotti dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query" access="public">
		<cfargument name="ids" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.ids )>

		<cfquery name="local.q" datasource="apirone">
			SELECT
				product_id::varchar,
				model_id::varchar,
				line_id::varchar,
				finish_id::varchar,
				catalog_bundle_id::varchar,
				attributes_important::varchar,
				*
			FROM products
			WHERE product_id = ANY(
				<cfqueryparam value="#idsList#" list="false" cfsqltype="varchar">::uuid[]
			)
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>
