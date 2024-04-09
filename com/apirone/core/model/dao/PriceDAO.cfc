<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="priceId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM prices
			WHERE price_id = <cfqueryparam cfsqltype="varchar" value="#arguments.priceId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="find" returntype="Query">

		<cfargument name="limit" required="true" type="Numeric" default="50">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="variantId" type="String">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				price_id,
				COUNT(price_id) OVER() AS total
			FROM
				prices
			WHERE 1=1
	
			<cfif !isNull( arguments.variantId ) >
				AND variant_id = <cfqueryparam value="#arguments.variantId#" cfsqltype="varchar">::uuid
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

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO prices(
				price,
                variant_id,
                discount_value,
                discount_type
			)
			VALUES (
				<cfqueryparam cfsqltype="float" value="#arguments.price.getValue()#">,
                <cfqueryparam cfsqltype="Varchar" value="#arguments.price.getVariantId()#">::uuid,
                <cfqueryparam cfsqltype="float" value="#arguments.price.getDiscount()#">,
                <cfqueryparam cfsqltype="Varchar" value="#arguments.price.getDiscountType()#">
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
				value = <cfqueryparam cfsqltype="float" value="#arguments.price.getValue()#">,
				variant_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.price.getVariantId()#">::uuid,
				discount_value =  <cfqueryparam cfsqltype="float" value="#arguments.price.getDiscount()#">,
				discount_type =  <cfqueryparam cfsqltype="Varchar" value="#arguments.price.getDiscountType()#">
			WHERE 
				price_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.price.getId()#">::uuid

		</cfquery>

		<cfreturn arguments.price.getId()>
	
	</cffunction>

	<cffunction name="delete" returntype="Boolean">

		<cfargument name="priceId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM prices
			WHERE
				price_id = <cfqueryparam cfsqltype="String" value="#arguments.priceId#">
		</cfquery>

		<cfreturn true>
	
	</cffunction>

</cfcomponent>