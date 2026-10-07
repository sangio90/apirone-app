<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<!---
		Registra un errore e, già che c'è, cancella quelli più vecchi di 180 giorni.
		Chiamato da apps/utils/errorReport.cfm.
	--->
	<cffunction name="insert" returntype="void">
		<cfargument name="data" type="Struct" required="true">

		<cfquery datasource="apirone">
			INSERT INTO error_logs (
				code,
				error_type,
				message,
				detail,
				template,
				line,
				event,
				routed_url,
				http_method,
				user_id,
				user_name,
				ip_address,
				user_agent,
				report_html
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#Left( arguments.data.code, 40 )#">,
				<cfqueryparam cfsqltype="varchar" value="#Left( arguments.data.errorType, 255 )#">,
				<cfqueryparam cfsqltype="longvarchar" value="#arguments.data.message#">,
				<cfqueryparam cfsqltype="longvarchar" value="#arguments.data.detail#">,
				<cfqueryparam cfsqltype="varchar" value="#Left( arguments.data.template, 500 )#">,
				<cfqueryparam cfsqltype="integer" value="#Val( arguments.data.line )#" null="#!IsNumeric( arguments.data.line )#">,
				<cfqueryparam cfsqltype="varchar" value="#Left( arguments.data.event, 255 )#">,
				<cfqueryparam cfsqltype="varchar" value="#Left( arguments.data.routedUrl, 1000 )#">,
				<cfqueryparam cfsqltype="varchar" value="#Left( arguments.data.httpMethod, 10 )#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.data.userId#" null="#!REFindNoCase( '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', arguments.data.userId )#">::uuid,
				<cfqueryparam cfsqltype="varchar" value="#Left( arguments.data.userName, 255 )#">,
				<cfqueryparam cfsqltype="varchar" value="#Left( arguments.data.ipAddress, 45 )#">,
				<cfqueryparam cfsqltype="varchar" value="#Left( arguments.data.userAgent, 1000 )#">,
				<cfqueryparam cfsqltype="longvarchar" value="#arguments.data.reportHtml#">
			)
		</cfquery>

		<cfquery datasource="apirone">
			DELETE FROM error_logs
			WHERE created_at < NOW() - INTERVAL '180 days'
		</cfquery>
	</cffunction>

	<!---
		Elenco per la pagina di consultazione, senza il report ( pesante ).
		str cerca in codice, messaggio, tipo, evento e utente.
	--->
	<cffunction name="search" returntype="Query">
		<cfargument name="str" type="String" default="">
		<cfargument name="limit" type="Numeric" default="50">
		<cfargument name="offset" type="Numeric" default="0">

		<cfset var like = "%" & Trim( arguments.str ) & "%">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				error_log_id,
				code,
				created_at,
				error_type,
				LEFT( message, 300 ) AS message,
				event,
				routed_url,
				user_name,
				COUNT(*) OVER () AS total
			FROM error_logs
			WHERE 1 = 1
			<cfif Len( Trim( arguments.str ) )>
				AND (
					code ILIKE <cfqueryparam cfsqltype="varchar" value="#like#">
					OR message ILIKE <cfqueryparam cfsqltype="varchar" value="#like#">
					OR error_type ILIKE <cfqueryparam cfsqltype="varchar" value="#like#">
					OR event ILIKE <cfqueryparam cfsqltype="varchar" value="#like#">
					OR user_name ILIKE <cfqueryparam cfsqltype="varchar" value="#like#">
				)
			</cfif>
			ORDER BY created_at DESC, error_log_id DESC
			LIMIT <cfqueryparam cfsqltype="integer" value="#arguments.limit#">
			OFFSET <cfqueryparam cfsqltype="integer" value="#arguments.offset#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="read" returntype="Query">
		<cfargument name="id" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM error_logs
			WHERE error_log_id = <cfqueryparam cfsqltype="bigint" value="#arguments.id#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

</cfcomponent>
