<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="priceId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM prices
			WHERE price_id = <cfqueryparam cfsqltype="Integer" value="#arguments.priceId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="find" returntype="Query">

		<cfargument name="str" type="String">
		<cfargument name="productId" type="String">
		<cfargument name="productItemId" type="Numeric">
		<cfargument name="typeId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="50">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				price_id,
				COUNT(price_id) OVER() AS total
			FROM
				prices
					INNER JOIN price_types USING ( price_type_id )
			WHERE 1=1
	
			<cfif !IsNull( arguments.str ) >
				AND price_type ILIKE <cfqueryparam value="#arguments.str#" cfsqltype="varchar">
			</cfif>

			<cfif !IsNull( arguments.typeId ) >
				AND price_types.price_type_id = <cfqueryparam value="#arguments.typeId#" cfsqltype="Varchar">
			</cfif>

			<cfif !IsNull( arguments.productId ) >
				AND prices.product_id = <cfqueryparam value="#arguments.productId#" cfsqltype="varchar">::uuid
			</cfif>

			<cfif !IsNull( arguments.productItemId ) >
				AND product_item_id = <cfqueryparam value="#arguments.productItemId#" cfsqltype="Integer">
			</cfif>

			<cfif arguments.limit GT 0>
				LIMIT  
					<cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET 
					<cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>

		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="insert" returntype="String">

		<cfargument name="price" type="com.apirone.core.model.bean.Price" required="true">

		<cfset var dbField = getDBField( arguments.price.getEntity().getKey() )>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO prices(
                amount,
                price_type_id,
				#dbField.name#
			)
			VALUES (
				<cfqueryparam cfsqltype="float" value="#arguments.price.getAmount()#">,
                <cfqueryparam cfsqltype="Varchar" value="#arguments.price.getType().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.price.getEntity().getValue()#">::#dbField.type#
			) RETURNING price_id
		</cfquery>

		<cfreturn q.price_id>
	
	</cffunction>

	<cffunction name="update" returntype="String">

		<cfargument name="price" type="com.apirone.core.model.bean.Price" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE 
				prices
			SET
				amount = <cfqueryparam cfsqltype="float" value="#arguments.price.getAmount()#">,
				method_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.price.getMethod().getId()#">
			WHERE 
				price_id = <cfqueryparam cfsqltype="Integer" value="#arguments.price.getId()#">
		</cfquery>

		<cfreturn arguments.price.getId()>
	
	</cffunction>

	<cffunction name="delete" returntype="Boolean">

		<cfargument name="priceId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM prices
			WHERE
				price_id = <cfqueryparam cfsqltype="Integer" value="#arguments.priceId#">
		</cfquery>

		<cfreturn true>
	
	</cffunction>

</cfcomponent>