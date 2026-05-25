<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_document_id::varchar,
				quotation_id::varchar,
				original_name,
				stored_name,
				directory,
				sort_order,
				created_at
			FROM quotation_documents
			WHERE quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationId#">::uuid
			ORDER BY sort_order ASC, created_at ASC
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="read" returntype="Query">
		<cfargument name="quotationDocumentId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_document_id::varchar,
				quotation_id::varchar,
				original_name,
				stored_name,
				directory,
				sort_order,
				created_at
			FROM quotation_documents
			WHERE quotation_document_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationDocumentId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="doc" type="com.apirone.core.model.bean.QuotationDocument" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_documents (
				quotation_id,
				original_name,
				stored_name,
				directory,
				sort_order
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.doc.getQuotationId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.doc.getOriginalName()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.doc.getStoredName()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.doc.getDirectory()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.doc.getSortOrder()#">
			)
			RETURNING quotation_document_id
		</cfquery>

		<cfreturn local.q.quotation_document_id.toString()>
	</cffunction>

	<cffunction name="updateSortOrder" returntype="void">
		<cfargument name="quotationDocumentId" type="String" required="true">
		<cfargument name="sortOrder"           type="Numeric" required="true">

		<cfquery datasource="apirone">
			UPDATE quotation_documents
			SET sort_order = <cfqueryparam cfsqltype="Integer" value="#arguments.sortOrder#">
			WHERE quotation_document_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationDocumentId#">::uuid
		</cfquery>
	</cffunction>

	<cffunction name="delete" returntype="void">
		<cfargument name="quotationDocumentId" type="String" required="true">

		<cfquery datasource="apirone">
			DELETE FROM quotation_documents
			WHERE quotation_document_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationDocumentId#">::uuid
		</cfquery>
	</cffunction>

</cfcomponent>
