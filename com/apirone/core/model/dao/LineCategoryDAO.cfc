<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="categoryId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM line_categories
			WHERE line_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.categoryId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>


	<cffunction returntype="Query" name="readByCode">

		<cfargument name="code" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM line_categories
			WHERE code = <cfqueryparam cfsqltype="varchar" value="#arguments.code#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="find" returntype="Query">

		<cfargument name="str" type="String">    	
		<cfargument name="lineId" type="Numeric">    

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="code">

        <cfquery name="local.q" datasource="apirone">
			SELECT
				line_category_id,
				COUNT(line_category_id) OVER() AS total
			FROM
				line_categories
				<cfif !IsNull( arguments.lineId )>
					INNER JOIN lines l USONG ( line_category_id )
				</cfif>

			WHERE 1=1
                
				<cfif Len( trim( arguments.str ) )>
					AND line_category ILIKE <cfqueryparam value="#arguments.str#%" cfsqltype="Varchar">
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

		<cfargument name="lineCategory" type="com.apirone.core.model.bean.LineCategory" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO line_categories (
				code,
				status_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.lineCategory.getCode()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.lineCategory.getStatus().getId()#">
			) RETURNING line_category_id
		</cfquery>

		<cfreturn q.line_category_id>
	
	</cffunction>


	<cffunction name="update" returntype="String">

		<cfargument name="lineCategory" type="com.apirone.core.model.bean.lineCategory" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				line_categories
			SET
				code = <cfqueryparam cfsqltype="Varchar" value="#trim(arguments.lineCategory.getCode())#">,
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineCategory.getStatus().getId()#">
			WHERE
				line_categorie_id = <cfqueryparam cfsqltype="Integer" value="#trim(arguments.lineCategory.getId())#">
		</cfquery>

		<cfreturn arguments.lineCategory.getId()>
	
	</cffunction>


	<cffunction name="delete" returntype="Boolean">

		<cfargument name="categoryId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM line_categories
			WHERE
				line_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.categoryId#">
		</cfquery>

		<cfreturn true>
	
	</cffunction>

</cfcomponent>