<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read">

		<cfargument name="documentItemId" type="String" required="true">

		<!----
			I need of product_id too
		---->
		<cfquery name="local.q" datasource="apirone">
			SELECT
			 	*
			FROM 
				document_items
					INNER JOIN variants USING (variant_id)	
			WHERE 
				document_item_id = <cfqueryparam cfsqltype="varchar" value="#arguments.documentItemId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="insert" returntype="String">

		<cfargument name="documentId" type="String" required="true">
		<cfargument name="DocumentItem" type="com.apirone.core.model.bean.DocumentItem" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO document_items (
				document_id,
				variant_id,
				price,
				quantity,
				status_id
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.documentId#">::uuid,
				<cfqueryparam cfsqltype="varchar" value="#arguments.DocumentItem.getProductVariant().getId()#">::uuid,
				<cfqueryparam cfsqltype="float" value="#arguments.DocumentItem.getPrice()#" scale="2">,
				<cfqueryparam cfsqltype="integer" value="#arguments.DocumentItem.getQuantity()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.DocumentItem.getStatus().getId()#">
			) RETURNING document_item_id
		</cfquery>
	
		<cfreturn q.document_item_id>
	</cffunction>

	<cffunction name="update" returntype="String">

		<cfargument name="document" type="com.apirone.core.model.bean.Product" required="true">

		<cfquery name="local.q" datasource="apirone">
			
			UPDATE document_items
			SET
			WHERE 
				document_item_id = <cfqueryparam cfsqltype="varchar" value="#arguments.product.getId()#">::uuid

		</cfquery>
	
		<cfreturn arguments.document.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">

		<cfargument name="documentId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM document_items 
			WHERE
				document_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.documentId#">::uuid
		</cfquery>

		<cfreturn true>
	
	</cffunction>

	<cffunction returntype="Query" name="find">

        <cfargument name="from" type="Date">
        <cfargument name="to" type="Date">

        <cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="quantity">
		
        <cfquery name="local.q" datasource="apirone">
			SELECT
				document_item_id,
				COUNT(document_item_id) OVER() AS total
			FROM
				document_items
			WHERE 1=1
			<cfif !isNull( arguments.documentId )>
				AND document_id = <cfqueryparam value="#arguments.documentId#" cfsqltype="String">::uuid
			</cfif>
			<cfif !isNull( arguments.from )>
				AND created_at >= <cfqueryparam value="#arguments.from#" cfsqltype="Date">
			</cfif>
			<cfif !isNull( arguments.from )>
				AND created_at <= <cfqueryparam value="#arguments.to#" cfsqltype="Date">
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
