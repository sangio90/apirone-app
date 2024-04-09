<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="categoryId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM product_categories
			WHERE product_category_id = <cfqueryparam cfsqltype="varchar" value="#arguments.categoryId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction returntype="Query" name="readByName">

		<cfargument name="category" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM product_categories
			WHERE product_category = <cfqueryparam cfsqltype="varchar" value="#arguments.category#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction returntype="Query" name="find">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="product_category">
		<cfargument name="str" type="String">    	
		<cfargument name="productId" type="String">    

        <cfquery name="local.q" datasource="apirone">
			SELECT
				product_category_id,
				COUNT(product_category_id) OVER() AS total
			FROM
				product_categories

				<cfif !isNull( arguments.productId )>
					INNER JOIN products_categories c
						USING (product_category_id)
				</cfif>
			WHERE 1=1
                
				<cfif Len( trim( arguments.str ) )>
					AND product_category ILIKE <cfqueryparam value="#arguments.str#%" cfsqltype="Varchar">
				</cfif>

				<cfif !isNull( arguments.productId )>
					AND c.product_id = <cfqueryparam value="#arguments.productId#" cfsqltype="Varchar">::uuid
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

	<cffunction name="insert" returntype="String">

		<cfargument name="productCategory" type="com.apirone.core.model.bean.ProductCategory" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO product_categories(
				product_category_id,
				product_category
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#trim(arguments.productCategory.getId())#">,
				<cfqueryparam cfsqltype="Varchar" value="#trim(arguments.productCategory.getName())#">
			) RETURNING product_category_id
		</cfquery>

		<cfreturn q.product_category_id>
	
	</cffunction>

	<cffunction name="update" returntype="String">

		<cfargument name="productCategory" type="com.apirone.core.model.bean.ProductCategory" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				product_categories
			SET
				product_category = <cfqueryparam cfsqltype="Varchar" value="#trim(arguments.productCategory.getName())#">
			WHERE
				product_category_id = <cfqueryparam cfsqltype="Varchar" value="#trim(arguments.productCategory.getId())#">
		</cfquery>

		<cfreturn arguments.productCategory.getId()>
	
	</cffunction>

	<cffunction name="delete" returntype="Boolean">

		<cfargument name="categoryId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM product_categories
			WHERE
				product_category_id = <cfqueryparam cfsqltype="String" value="#arguments.categoryId#">
		</cfquery>

		<cfreturn true>
	
	</cffunction>

</cfcomponent>