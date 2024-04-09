<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cfproperty name="Configuration" type="com.apirone.core.model.bean.Configuration"/>

	<cffunction name="read">

		<cfargument name="productId" type="String" required="true">

		<cfquery name="local.q" datasource="zerobenefit">
			SELECT
			 	*
			FROM 
				products
			WHERE 
				product_id = <cfqueryparam cfsqltype="varchar" value="#arguments.productId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="insert" returntype="String">

		<cfargument name="product" type="com.apirone.core.model.bean.Product" required="true">

		<cfquery name="local.q" datasource="zerobenefit">
			INSERT INTO products (
				product,
				description,
				code,
				status_id,
				expiration_at,
				variant_type_id,
				company_id
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.product.getName()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.product.getDescription()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.product.getCode()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.product.getStatus().getId()#">,
				<cfqueryparam cfsqltype="timestamp" value="#arguments.product.getExpirationAt()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.product.getVariantType().getId()#">::uuid,
				<cfqueryparam cfsqltype="varchar" value="#arguments.product.getCompany().getId()#">::uuid
			) RETURNING product_id
		</cfquery>
	
		<cfreturn q.product_id>
	</cffunction>

	<cffunction name="update" returntype="String">

		<cfargument name="product" type="com.apirone.core.model.bean.Product" required="true">

		<cfquery name="local.q" datasource="zerobenefit">
			
			UPDATE products
			SET
			      product         = <cfqueryparam cfsqltype = "varchar" value   = "#arguments.product.getName()#">,
			      description     = <cfqueryparam cfsqltype = "varchar" value   = "#arguments.product.getDescription()#">,
			      code            = <cfqueryparam cfsqltype = "varchar" value   = "#arguments.product.getCode()#">,
			      status_id       = <cfqueryparam cfsqltype = "varchar" value   = "#arguments.product.getStatus().getId()#">,
			      expiration_at   = <cfqueryparam cfsqltype = "timestamp" value = "#arguments.product.getExpirationAt()#">,
			      variant_type_id = <cfqueryparam cfsqltype = "varchar" value   = "#arguments.product.getVariantType().getId()#">::uuid,
			      company_id      = <cfqueryparam cfsqltype = "varchar" value   = "#arguments.product.getCompanyId()#">::uuid
			WHERE 
				product_id      = <cfqueryparam cfsqltype = "varchar" value   = "#arguments.product.getId()#">::uuid

		</cfquery>
	
		<cfreturn arguments.product.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">

		<cfargument name="productId" type="String" required="true">

		<cfquery name="local.q" datasource="zerobenefit">
			DELETE
			FROM products 
			WHERE
				product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
		</cfquery>

		<cfreturn true>
	
	</cffunction>


	<!--------
		PRODUCTS_CATEGORIES
	--->
	<cffunction name="addCategory" returntype="String">

		<cfargument name="productId" type="String" required="true">
		<cfargument name="productCategoryId" type="String" required="true">

		<cfquery name="local.q" datasource="zerobenefit">
			INSERT INTO products_categories (
				product_id,
				product_category_id
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.productId#">::uuid,
				<cfqueryparam cfsqltype="varchar" value="#arguments.productCategoryId#">
			) RETURNING product_id
		</cfquery>
	
		<cfreturn q.product_id>
	
	</cffunction>

	<cffunction name="removeCategory" returntype="Boolean">

		<cfargument name="productId" type="String" required="true">
		<cfargument name="productCategoryId" type="String" required="true">

		<cfquery name="local.q" datasource="zerobenefit">
			DELETE FROM products_categories
			WHERE 
				product_id 			= <cfqueryparam cfsqltype="varchar" value="#arguments.productId#">::uuid
			AND	product_category_id = <cfqueryparam cfsqltype="varchar" value="#arguments.productCategoryId#">
		</cfquery>
	
		<cfreturn true>
	
	</cffunction>

	<cffunction returntype="Query" name="find">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="product_id">
		<cfargument name="code" type="String" >

        <cfquery name="local.q" datasource="zerobenefit">
			SELECT
				product_id,
				COUNT(product_id) OVER() AS total
			FROM
				products
			WHERE 1=1
			<cfif !isNull( arguments.code )>
				AND code = <cfqueryparam value="#arguments.code#" cfsqltype="varchar">
			</cfif>
                
			ORDER BY 
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GT 0>
				LIMIT  
					<cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET 
					<cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>

		<cfreturn local.q>

	</cffunction>	

</cfcomponent>