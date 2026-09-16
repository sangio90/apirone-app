<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<!---
		Lock/stato sincronizzazione CRM: riga singola (id = 1) in crm_sync_status.
		Stessa logica di VerticaleSyncDAO ma su una tabella di stato separata:
		una sync di Verticale e una del CRM devono poter girare insieme senza
		bloccarsi a vicenda, sono sistemi indipendenti.
	--->

	<cffunction name="tryAcquireLock" access="public" returntype="Boolean">
		<cfargument name="userId" type="String" required="false" default="">

		<cfquery name="local.q" datasource="apirone" result="local.result">
			UPDATE crm_sync_status
			SET
				running = true,
				started_at = now(),
				started_by_user_id = <cfqueryparam cfsqltype="varchar" value="#arguments.userId#" null="#!Len( arguments.userId )#">::uuid,
				last_error = NULL
			WHERE
				id = 1
				AND running = false
		</cfquery>

		<cfreturn local.result.recordCount GT 0>
	</cffunction>

	<cffunction name="releaseLock" access="public" returntype="void">
		<cfargument name="succeeded" type="Boolean" required="true">
		<cfargument name="errorMessage" type="String" required="false" default="">

		<cfif arguments.succeeded>
			<cfquery datasource="apirone">
				UPDATE crm_sync_status
				SET
					running = false,
					finished_at = now(),
					last_error = NULL
				WHERE
					id = 1
			</cfquery>
		<cfelse>
			<cfquery datasource="apirone">
				UPDATE crm_sync_status
				SET
					running = false,
					last_error = <cfqueryparam cfsqltype="varchar" value="#Left( arguments.errorMessage, 4000 )#">
				WHERE
					id = 1
			</cfquery>
		</cfif>
	</cffunction>

	<cffunction name="getStatus" access="public" returntype="Query">
		<cfquery name="local.q" datasource="apirone">
			SELECT running, finished_at
			FROM crm_sync_status
			WHERE id = 1
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Un metodo syncX() per entità CRM: pagina l'API REST (limit=1000) finché
		non ha letto tutti i record, e sostituisce per intero la tabella locale
		corrispondente. Il record intero (compresi i campi custom_*) viene
		conservato in "data" JSONB così CrmMapper continua a deserializzarlo
		esattamente come quando arrivava dal vivo dalla chiamata HTTP.
	--->

	<cffunction name="syncAccounts" access="public" returntype="void">
		<cfset var api = new com.apirone.core.model.service.CrmApiService().init()>

		<cfset syncEntity(
			tableName = "crm_accounts",
			fetchPage = function( limit, offset ){
				return api.searchCustomers( str = "", limit = arguments.limit, offset = arguments.offset );
			},
			nameFn = function( record ){
				return Left( Trim( record.name ?: "" ), 255 );
			}
		)>
	</cffunction>

	<cffunction name="syncLeads" access="public" returntype="void">
		<cfset var api = new com.apirone.core.model.service.CrmApiService().init()>

		<cfset syncEntity(
			tableName = "crm_leads",
			fetchPage = function( limit, offset ){
				return api.searchLeads( str = "", limit = arguments.limit, offset = arguments.offset );
			},
			nameFn = function( record ){
				return Left( Trim( Trim( record.first_name ?: "" ) & " " & Trim( record.last_name ?: "" ) ), 255 );
			}
		)>
	</cffunction>

	<cffunction name="syncOpportunities" access="public" returntype="void">
		<cfset var api = new com.apirone.core.model.service.CrmApiService().init()>

		<cfset syncEntity(
			tableName = "crm_opportunities",
			fetchPage = function( limit, offset ){
				return api.searchOpportunities( str = "", limit = arguments.limit, offset = arguments.offset );
			},
			nameFn = function( record ){
				return Left( Trim( record.name ?: "" ), 255 );
			}
		)>
	</cffunction>

	<!---
		private methods
	--->

	<cffunction name="syncEntity" access="private" returntype="void">
		<cfargument name="tableName" type="String" required="true">
		<cfargument name="fetchPage" type="any" required="true">
		<cfargument name="nameFn" type="any" required="true">

		<cfset var safeTableName = sanitizeSQL( arguments.tableName )>
		<cfset var pageSize = 1000>

		<cftransaction>

			<cfquery datasource="apirone">
				DELETE FROM #safeTableName#
			</cfquery>

			<cfset var offset = 0>
			<cfset var total = 1>
			<cfset var gotFirstPage = false>

			<cfloop condition="offset LT total">
				<cfset var page = arguments.fetchPage( pageSize, offset )>

				<cfif !gotFirstPage>
					<cfset total = Val( page.total ?: 0 )>
					<cfset gotFirstPage = true>
				</cfif>

				<cfif !ArrayLen( page.data ?: [] )>
					<cfbreak>
				</cfif>

				<cfset insertBatch( safeTableName, page.data, arguments.nameFn )>

				<cfset offset += ArrayLen( page.data )>
			</cfloop>

		</cftransaction>
	</cffunction>

	<cffunction name="insertBatch" access="private" returntype="void">
		<cfargument name="tableName" type="String" required="true">
		<cfargument name="records" type="Array" required="true">
		<cfargument name="nameFn" type="any" required="true">

		<cfif !ArrayLen( arguments.records )>
			<cfreturn>
		</cfif>

		<cfquery datasource="apirone">
			INSERT INTO #arguments.tableName# ( id, name, deleted, data )
			VALUES
			<cfloop from="1" to="#ArrayLen( arguments.records )#" index="i">
				<cfif i GT 1>,</cfif>
				<cfset var record = arguments.records[ i ]>
				(
					<cfqueryparam value="#record.id#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.nameFn( record )#" cfsqltype="varchar">,
					<cfqueryparam value="#( Val( record.deleted ?: 0 ) EQ 1 )#" cfsqltype="bit">,
					<cfqueryparam value="#SerializeJSON( record )#" cfsqltype="varchar">::jsonb
				)
			</cfloop>
		</cfquery>
	</cffunction>

</cfcomponent>
