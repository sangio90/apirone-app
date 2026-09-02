<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_proforma_id::varchar,
				quotation_id::varchar,
				progressivo,
				percentuale,
				importo,
				stored_name,
				directory,
				created_at,
				created_by::varchar
			FROM quotation_proformas
			WHERE quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationId#">::uuid
			ORDER BY created_at DESC
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="read" returntype="Query">
		<cfargument name="quotationProformaId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_proforma_id::varchar,
				quotation_id::varchar,
				progressivo,
				percentuale,
				importo,
				stored_name,
				directory,
				created_at,
				created_by::varchar
			FROM quotation_proformas
			WHERE quotation_proforma_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationProformaId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="existsProgressivo" returntype="Boolean">
		<cfargument name="quotationId" type="String" required="true">
		<cfargument name="progressivo" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT 1
			FROM quotation_proformas
			WHERE quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationId#">::uuid
			  AND TRIM( progressivo ) = <cfqueryparam cfsqltype="Varchar" value="#Trim( arguments.progressivo )#">
			LIMIT 1
		</cfquery>

		<cfreturn local.q.recordCount GT 0>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="proforma" type="com.apirone.core.model.bean.QuotationProforma" required="true">

		<!---
			Niente attributo "result" su questa query: su questo Lucee, insieme a
			"name" su una INSERT ... RETURNING, impedisce la creazione della
			variabile di query e local.q resta inesistente. Non serviva.
		--->
		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_proformas (
				quotation_id,
				progressivo,
				percentuale,
				importo,
				stored_name,
				directory,
				created_by
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.proforma.getQuotationId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.proforma.getProgressivo()#">,
				<!--- percentuale e importo sono alternativi: quello non usato va a NULL,
				      il vincolo sul DB rifiuta la riga se sono valorizzati entrambi --->
				<cfqueryparam
					cfsqltype="Decimal"
					value="#arguments.proforma.getPercentuale()#"
					null="#IsNull( arguments.proforma.getPercentuale() )#">,
				<cfqueryparam
					cfsqltype="Decimal"
					value="#arguments.proforma.getImporto()#"
					null="#IsNull( arguments.proforma.getImporto() )#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.proforma.getStoredName()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.proforma.getDirectory()#">,
				<cfqueryparam
					cfsqltype="Varchar"
					value="#arguments.proforma.getCreatedBy()#"
					null="#IsNull( arguments.proforma.getCreatedBy() )#">::uuid
			)
			<!---
				Nessun ON CONFLICT: un progressivo già usato per questo preventivo
				deve essere rifiutato, non sovrascritto. Il vincolo unico sul DB è
				l'ultima difesa; il controllo esplicito sta in existsProgressivo(),
				chiamato prima ancora di generare il PDF.
			--->
			RETURNING quotation_proforma_id
		</cfquery>

		<cfreturn local.q.quotation_proforma_id.toString()>
	</cffunction>

	<cffunction name="delete" returntype="void">
		<cfargument name="quotationProformaId" type="String" required="true">

		<cfquery datasource="apirone">
			DELETE FROM quotation_proformas
			WHERE quotation_proforma_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationProformaId#">::uuid
		</cfquery>
	</cffunction>

</cfcomponent>
