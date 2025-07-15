<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="productId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				product_id::varchar,
				size_id::varchar,
				line_id::varchar,
				finish_id::varchar,
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
		<cfargument name="sizeId" type="String">
		<cfargument name="finishId" type="String">
		<cfargument name="excludedIds" type="Array">
		<cfargument name="str" type="String">

		<cfargument name="orderby" required="true" type="String" default="product.product_id">
		<cfargument name="limit" required="true" type="Numeric" default="15">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT product_id::varchar
			FROM
				products
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

				<cfif !IsNull( arguments.sizeId )>
					AND products.size_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.sizeId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.excludedCategoryIds ) AND ArrayLen( arguments.excludedCategoryIds )>
					AND products.product_category_id NOT IN (<cfqueryparam cfsqltype="Integer" value="#arguments.excludedCategoryIds#" list="yes">)
				</cfif>

			ORDER BY
				<!--- #super.sanitizeSQL( arguments.orderBy )# - ---> <!--- TODO: dovrei fare la inner se l'ordinamento prevede product.name --->
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

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO products (
				size_id,
				line_id,
				finish_id,
				code,
				product_category_id,
				status_id
			)
			VALUES (
				<cfif !IsNull( arguments.product.getSize() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.product?.getSize()?.getId()#">::uuid
				<cfelse>
					NULL
				</cfif>
				,
				<cfif !IsNull( arguments.product.getLine() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.product?.getLine()?.getId()#">::uuid
				<cfelse>
					NULL
				</cfif>
				,
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
				<cfqueryparam cfsqltype="Integer" value="#arguments.product.getCategory().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.product.getStatus().getId()#">
			) RETURNING product_id
		</cfquery>

		<cfreturn local.q.product_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="product" type="com.apirone.core.model.bean.Product" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE products
			SET
				size_id =
					<cfif !IsNull( arguments.product.getSize() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.product?.getSize()?.getId()#">::uuid
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
				product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.product.getCategory().getId()#">,
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
</cfcomponent>
