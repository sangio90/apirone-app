<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read">

		<cfargument name="documentId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
			 	*
			FROM 
				documents
			WHERE 
				document_id = <cfqueryparam cfsqltype="varchar" value="#arguments.documentId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="insert" returntype="String">

		<cfargument name="document" type="com.apirone.core.model.bean.Document" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO documents (
				employee_id,
				status_id
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.document.getEmployee().getId()#">::uuid,
				<cfqueryparam cfsqltype="varchar" value="#arguments.document.getStatus().getId()#">
			) RETURNING document_id
		</cfquery>
	
		<cfreturn q.document_id>
	</cffunction>

	<cffunction name="update" returntype="String">

		<cfargument name="document" type="com.apirone.core.model.bean.RawProduct" required="true">

		<cfquery name="local.q" datasource="apirone">
			
			UPDATE documents
			SET
			WHERE 
				document_id = <cfqueryparam cfsqltype="varchar" value="#arguments.product.getId()#">::uuid

		</cfquery>
	
		<cfreturn arguments.document.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">

		<cfargument name="documentId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM documents 
			WHERE
				document_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.documentId#">::uuid
		</cfquery>

		<cfreturn true>
	
	</cffunction>

	<cffunction returntype="Query" name="find">

        <cfargument name="code" type="Numeric">
        <cfargument name="from" type="Date">
        <cfargument name="to" type="Date">

        <cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="code">
		
        <cfquery name="local.q" datasource="apirone">
			SELECT
				document_id,
				COUNT(document_id) OVER() AS total
			FROM
				documents
			WHERE 1=1
			<cfif !isNull( arguments.code )>
				AND code = <cfqueryparam value="#arguments.code#" cfsqltype="varchar">
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
