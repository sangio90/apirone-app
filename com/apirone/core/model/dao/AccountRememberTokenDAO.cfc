<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="insert" returntype="void">
		<cfargument name="accountId" type="String" required="true">
		<cfargument name="hashedToken" type="String" required="true">
		<cfargument name="expiresAt" type="String" required="true">

		<cfquery datasource="apirone">
			INSERT INTO account_remember_tokens (
				account_id,
				token,
				expires_at
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.accountId#">::uuid,
				<cfqueryparam cfsqltype="varchar" value="#arguments.hashedToken#">,
				<cfqueryparam cfsqltype="timestamp" value="#arguments.expiresAt#">
			)
		</cfquery>
	</cffunction>

	<!---
		Restituisce l'account_id del token, solo se non scaduto. Nessuna riga = token
		inesistente o scaduto: chi chiama tratta i due casi allo stesso modo (richiede
		un nuovo login).
	--->
	<cffunction name="findValidByToken" returntype="Query">
		<cfargument name="hashedToken" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT account_id::varchar AS account_id
			FROM account_remember_tokens
			WHERE
				token = <cfqueryparam cfsqltype="varchar" value="#arguments.hashedToken#">
				AND expires_at > NOW()
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Revoca un singolo token (logout sul dispositivo corrente): gli altri token dello
		stesso account, se presenti (altri browser/dispositivi), restano validi.
	--->
	<cffunction name="deleteByToken" returntype="void">
		<cfargument name="hashedToken" type="String" required="true">

		<cfquery datasource="apirone">
			DELETE FROM account_remember_tokens
			WHERE token = <cfqueryparam cfsqltype="varchar" value="#arguments.hashedToken#">
		</cfquery>
	</cffunction>

	<!---
		Pulizia dei token scaduti. Non è critico per la correttezza (findValidByToken
		filtra già su expires_at), ma evita che la tabella cresca all'infinito.
	--->
	<cffunction name="deleteExpired" returntype="void">
		<cfquery datasource="apirone">
			DELETE FROM account_remember_tokens
			WHERE expires_at <= NOW()
		</cfquery>
	</cffunction>

</cfcomponent>
