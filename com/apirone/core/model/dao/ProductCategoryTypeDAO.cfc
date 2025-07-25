<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction returntype="Query" name="read">
		<cfargument name="productCategoryTypeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM product_category_types
			WHERE product_category_type_id = <cfqueryparam cfsqltype="String" value="#arguments.productCategoryTypeId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		
        <cfargument name="str" type="String">
		<cfargument name="statusId" type="String">
		
        <cfargument name="orderby" type="String" default="product_category_type">

		<cfquery name="local.q" datasource="apirone">
			SELECT 
                product_category_type_id,
				COUNT(product_category_type_id) OVER() AS total
			FROM
				product_category_types
			WHERE 1=1

				<cfif Len( Trim( arguments.str ) )>
					AND ( product_category_type ILIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="Varchar">
                    OR code LIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="Varchar"> )
				</cfif>

				<cfif Len( Trim( arguments.statusId ) )>
					AND product_category_types.status_id = <cfqueryparam value="#arguments.statusId#" cfsqltype="Varchar">
				</cfif>

			ORDER BY
				#super.sanitizeSQL( arguments.orderby )#
		</cfquery>

		<cfreturn local.q>
	</cffunction>

</cfcomponent>
