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
				*
			FROM
				products
			WHERE
				product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
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
			SELECT
				product_id::varchar,
				COUNT(line_id) OVER() AS total
			FROM
				products
					INNER JOIN product_categories USING ( product_category_id )
					<cfif !IsNull( arguments.str )>
						INNER JOIN texts USING ( product_id )
					</cfif>

			WHERE 1=1

				<cfif !IsNull( arguments.str )>
					AND texts.text ILIKE <cfqueryparam cfsqltype="varchar" value="%#arguments.str#%">
				</cfif>

				<cfif !IsNull( arguments.lineId )>
					AND products.line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.finishId )>
					AND products.finish_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.finishId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.catalogBundleId )>
					AND products.catalog_bundle_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.catalogBundleId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.modelId )>
					AND products.model_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.modelId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.excludedCategoryIds ) AND ArrayLen( arguments.excludedCategoryIds )>
					AND products.product_category_id NOT IN (<cfqueryparam cfsqltype="Integer" value="#arguments.excludedCategoryIds#" list="yes">)
				</cfif>

				<cfif !IsNull( arguments.categoryId )>
					AND products.product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.categoryId#">
				</cfif>

				<cfif !IsNull( arguments.categoryModeId )>
					AND product_categories.mode_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.categoryModeId#">
				</cfif>

			ORDER BY
				<!--- #super.sanitizeSQL( arguments.orderBy )# - --->
				<!--- TODO: dovrei fare la inner se l'ordinamento prevede product.name --->
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
					<cfqueryparam cfsqltype="Integer" value="#arguments.product.getCategory().getId()#">
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
				<cfif IsInstanceOf( arguments.product, "com.apirone.core.model.bean.ProductBase" )>
					product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.product.getCategory().getId()#">,
				</cfif>
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.product.getStatus().getId()#">
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
				 catalog_bundle_id in (
					SELECT catalog_bundle_id
					FROM catalog_bundles
					WHERE
						product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.categoryId#">::uuid AND
						line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
				)
			RETURNING product_id
		</cfquery>

		<cffile
			file  ="#ExpandPath( "/debug.log" )#"
			output="line:#lineId#, category: #categoryId#; cancellati: #local.q.recordcount#"
			action="APPEND"
		>
		<cfreturn true>
	</cffunction>
</cfcomponent>
