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

	<cffunction name="find" returntype="Query">
		<cfargument name="lineId" type="String">
		<cfargument name="sizeId" type="String">
		<cfargument name="finishId" type="String">

		<cfquery name="local.q" datasource="apirone">
			SELECT product_id::varchar
			FROM
				products
			WHERE 1=1

				<cfif !isNull( arguments.lineId )>
					AND line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
				</cfif>

				<cfif !isNull( arguments.finishId )>
					AND finish_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.finishId#">::uuid
				</cfif>

				<cfif !isNull( arguments.sizeId )>
					AND size_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.sizeId#">::uuid
				</cfif>

			<cfif arguments.limit GTE 0>
				LIMIT
					<cfqueryparam cfsqltype="integer" value="#arguments.limit#">
				OFFSET
					<cfqueryparam cfsqltype="integer" value="#arguments.offset#">
			</cfif>

			ORDER BY
				created_at
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="product" type="com.apirone.core.model.bean.Product" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO products (
				size_id,
				line_id,
				finish_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.product.getSize().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.product.getLine().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.product.getFinish().getId()#">::uuid
			) RETURNING product_id
		</cfquery>

		<cfreturn local.q.product_id.toString()>
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
