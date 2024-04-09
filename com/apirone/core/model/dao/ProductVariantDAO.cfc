<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="productVariantId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM variants
			WHERE variant_id = <cfqueryparam cfsqltype="varchar" value="#arguments.productVariantId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="find" returntype="Query">

		<cfargument name="limit" required="true" type="Numeric" default="50">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="productId" type="String">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				variant_id,
				COUNT(variant_id) OVER() AS total
			FROM
				variants
			WHERE 1=1
	
			<cfif !isNull( arguments.productId ) >
				AND product_id = <cfqueryparam value="#arguments.productId#" cfsqltype="varchar">::uuid
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

		<cfargument name="productVariant" type="com.apirone.core.model.bean.ProductVariant" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO variants (
				variant,
				product_id,
				status_id,
				description
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.productVariant.getName()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.productVariant.getProductId()#">::uuid,
				<cfqueryparam cfsqltype="varchar" value="#arguments.productVariant.getStatus().getId()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.productVariant.getDescription()#">
			) RETURNING variant_id
		</cfquery>
	
		<cfreturn q.variant_id>
	</cffunction>

	<cffunction name="update" returntype="String">

		<cfargument name="productVariant" type="com.apirone.core.model.bean.ProductVariant" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE 
				variants
			SET
				variant = <cfqueryparam cfsqltype="varchar" value="#arguments.productVariant.getName()#">,
				product_id = <cfqueryparam cfsqltype="varchar" value="#arguments.productVariant.getProductId()#">::uuid,
				status_id = <cfqueryparam cfsqltype="varchar" value="#arguments.productVariant.getStatus().getId()#">,
				description = <cfqueryparam cfsqltype="varchar" value="#arguments.productVariant.getDescription()#">
				WHERE variant_id = 	<cfqueryparam cfsqltype="varchar" value="#arguments.productVariant.getId()#">::uuid

		</cfquery>
	
		<cfreturn arguments.productVariant.getId()>
	</cffunction>

	<cffunction returntype="Boolean" name="delete">

		<cfargument name="productVariantId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM variants
			WHERE variant_id = <cfqueryparam cfsqltype="varchar" value="#arguments.productVariantId#">::uuid
		</cfquery>

		<cfreturn true>

	</cffunction>

</cfcomponent>