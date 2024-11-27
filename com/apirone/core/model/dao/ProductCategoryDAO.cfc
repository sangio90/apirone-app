<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="categoryId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM product_categories
			WHERE product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.categoryId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction returntype="Query" name="readByCode">

		<cfargument name="code" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM product_categories
			WHERE code = <cfqueryparam cfsqltype="varchar" value="#arguments.code#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="find" returntype="Query">

		<cfargument name="str" type="String">    	
		<cfargument name="statusId" type="String">    	
		<cfargument name="lineId" type="Numeric">    

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="code">

        <cfquery name="local.q" datasource="apirone">
			SELECT DISTINCT
				product_category_id,
				COUNT(product_category_id) OVER() AS total
			FROM
				product_categories
					INNER JOIN texts USING ( product_category_id )
				
				<cfif !IsNull( arguments.lineId )>
					INNER JOIN lines l USING ( product_category_id )
				</cfif>

			WHERE 1=1
                
				<cfif Len( trim( arguments.str ) )>
					AND texts.text ILIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="Varchar">
				</cfif>

				<cfif Len( trim( arguments.statusId ) )>
					AND product_categories.status_id = <cfqueryparam value="#arguments.statusId#" cfsqltype="Varchar">
				</cfif>

				<cfif !isNull( arguments.lineId )>
					AND l.line_id = <cfqueryparam value="#arguments.lineId#" cfsqltype="Varchar">
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


	<cffunction name="insert" returntype="Numeric">

		<cfargument name="ProductCategory" type="com.apirone.core.model.bean.ProductCategory" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO product_categories (
				code,
				status_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.ProductCategory.getCode()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.ProductCategory.getStatus().getId()#">
			) RETURNING product_category_id
		</cfquery>

		<cfreturn q.product_category_id>
	
	</cffunction>


	<cffunction name="update" returntype="String">

		<cfargument name="ProductCategory" type="com.apirone.core.model.bean.ProductCategory" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				product_categories
			SET
				code = <cfqueryparam cfsqltype="Varchar" value="#trim(arguments.ProductCategory.getCode())#">,
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.ProductCategory.getStatus().getId()#">
			WHERE
				line_categorie_id = <cfqueryparam cfsqltype="Integer" value="#trim(arguments.ProductCategory.getId())#">
		</cfquery>

		<cfreturn arguments.ProductCategory.getId()>
	
	</cffunction>


	<cffunction name="delete" returntype="Numeric">
		<cfargument name="productCategoryId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				product_categories
			WHERE
				product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productCategoryId#">
			RETURNING product_category_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

</cfcomponent>