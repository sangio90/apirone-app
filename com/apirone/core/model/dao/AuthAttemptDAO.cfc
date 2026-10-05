<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<!---
		Registra un tentativo e, già che c'è, pulisce le righe più vecchie di un giorno
		(nessuna finestra di rate limit è così lunga).
	--->
	<cffunction name="insert" returntype="void">
		<cfargument name="kind" type="String" required="true">
		<cfargument name="identifier" type="String" required="true">
		<cfargument name="ipAddress" type="String" required="true">

		<cfquery datasource="apirone">
			INSERT INTO auth_attempts (
				kind,
				identifier,
				ip_address
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.kind#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.identifier#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.ipAddress#">
			)
		</cfquery>

		<cfquery datasource="apirone">
			DELETE FROM auth_attempts
			WHERE created_at < NOW() - INTERVAL '1 day'
		</cfquery>
	</cffunction>

	<!---
		Tentativi nella finestra, contati per account, per IP e per la coppia account+IP.
	--->
	<cffunction name="countRecent" returntype="Query">
		<cfargument name="kind" type="String" required="true">
		<cfargument name="identifier" type="String" required="true">
		<cfargument name="ipAddress" type="String" required="true">
		<cfargument name="minutes" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				COUNT(*) FILTER ( WHERE identifier = <cfqueryparam cfsqltype="varchar" value="#arguments.identifier#"> ) AS by_identifier,
				COUNT(*) FILTER ( WHERE ip_address = <cfqueryparam cfsqltype="varchar" value="#arguments.ipAddress#"> ) AS by_ip,
				COUNT(*) FILTER (
					WHERE identifier = <cfqueryparam cfsqltype="varchar" value="#arguments.identifier#">
					AND ip_address = <cfqueryparam cfsqltype="varchar" value="#arguments.ipAddress#">
				) AS by_pair
			FROM auth_attempts
			WHERE
				kind = <cfqueryparam cfsqltype="varchar" value="#arguments.kind#">
				AND created_at > NOW() - make_interval( mins => <cfqueryparam cfsqltype="integer" value="#arguments.minutes#"> )
				AND (
					identifier = <cfqueryparam cfsqltype="varchar" value="#arguments.identifier#">
					OR ip_address = <cfqueryparam cfsqltype="varchar" value="#arguments.ipAddress#">
				)
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="deleteByIdentifier" returntype="void">
		<cfargument name="kind" type="String" required="true">
		<cfargument name="identifier" type="String" required="true">

		<cfquery datasource="apirone">
			DELETE FROM auth_attempts
			WHERE
				kind = <cfqueryparam cfsqltype="varchar" value="#arguments.kind#">
				AND identifier = <cfqueryparam cfsqltype="varchar" value="#arguments.identifier#">
		</cfquery>
	</cffunction>

</cfcomponent>
