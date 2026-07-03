<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cfproperty name="Configuration" inject="bean:Configuration"/>

	<cffunction name="read" returntype="Query">

		<cfargument name="accountId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				pgp_sym_decrypt(
					email::bytea,
					<cfqueryparam cfsqltype="varchar" value="#variables.configuration.get('encryptKey')#">
				) AS email,
				account_id::varchar,
				--roles,
				*
			FROM
				membership.accounts
			WHERE
				account_id = <cfqueryparam cfsqltype="varchar" value="#arguments.accountId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="readByEmail" returntype="Query">

		<cfargument name="email" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
			 	account_id::varchar,
				pgp_sym_decrypt(
					email::bytea,
					<cfqueryparam cfsqltype="varchar" value="#variables.configuration.get('encryptKey')#">
				) AS email
			FROM
				membership.accounts
			WHERE
				pgp_sym_decrypt(email::bytea, <cfqueryparam cfsqltype="varchar" value="#variables.configuration.get("encryptKey")#">) = <cfqueryparam cfsqltype="varchar" value="#arguments.email#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="find" returntype="Query">

		<cfargument name="email" type="String">
		<cfargument name="str" type="String">
		<!---
		<cfargument name="roleId" type="String">
		<cfargument name="langId" type="String">
		---->
		<cfargument name="statusId" type="String">
		<cfargument name="hasAgenteVerticale" type="Boolean">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="code">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				account_id::varchar,
				COUNT(account_id) OVER() AS total,
				pgp_sym_decrypt( email::bytea, <cfqueryparam cfsqltype="varchar" value="#variables.configuration.get('encryptKey')#"> ) AS email
			FROM
				membership.accounts
			WHERE 1=1

				<cfif !IsNull( arguments.email )>
					AND pgp_sym_decrypt(email::bytea, <cfqueryparam cfsqltype="varchar" value="#variables.configuration.get("encryptKey")#">) = <cfqueryparam cfsqltype="varchar" value="#arguments.email#">
				</cfif>

				<cfif !IsNull( arguments.str )>
					AND (
						pgp_sym_decrypt(email::bytea, <cfqueryparam cfsqltype="varchar" value="#variables.configuration.get("encryptKey")#">)
						ILIKE <cfqueryparam cfsqltype="varchar" value="%#arguments.str#%">
						OR
						account_id::varchar ILIKE <cfqueryparam cfsqltype="varchar" value="%#arguments.str#">
					)
				</cfif>

				<cfif !IsNull( arguments.statusId )>
					AND status_id ILIKE <cfqueryparam cfsqltype="varchar" value="#arguments.statusId#">
				</cfif>

				<cfif !IsNull( arguments.hasAgenteVerticale ) AND arguments.hasAgenteVerticale>
					AND id_agente_verticale IS NOT NULL
				</cfif>

				<!----
				<cfif !IsNull( arguments.langId )>
					AND lang_id ILIKE <cfqueryparam cfsqltype="varchar" value="#arguments.langId#">
				</cfif>

				<cfif !IsNull( arguments.roleId )>
					AND role_id ILIKE <cfqueryparam cfsqltype="varchar" value="#arguments.roleId#">
				</cfif>
				----->

			ORDER BY
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GTE 0>
				LIMIT
					<cfqueryparam cfsqltype="integer" value="#arguments.limit#">
				OFFSET
					<cfqueryparam cfsqltype="integer" value="#arguments.offset#">
			</cfif>
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="insert" returntype="String">

		<cfargument name="account" type="com.apirone.core.model.bean.Account" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO membership.accounts (
				email,
				status_id,
				account,
				id_utente_verticale,
				id_agente_verticale
			)
			VALUES (
				pgp_sym_encrypt(
					<cfqueryparam cfsqltype="varchar" value="#arguments.account.getEmail()#">,
					<cfqueryparam cfsqltype="varchar" value='#variables.configuration.get('encryptKey')#'>
				)::varchar,
				<cfqueryparam cfsqltype="varchar" value="#arguments.account.getStatus().getId()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.account.getName()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.account.getIdUtenteVerticale()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.account.getIdAgenteVerticale()#">
			) RETURNING account_id::varchar
		</cfquery>

		<cfreturn q.account_id>
	</cffunction>

	<cffunction name="update" returntype="String">

		<cfargument name="account" type="com.apirone.core.model.bean.Account" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE membership.accounts
			SET
				account = <cfqueryparam cfsqltype="varchar" value="#arguments.account.getName()#">,
				email = pgp_sym_encrypt(
					<cfqueryparam cfsqltype="varchar" value="#arguments.account.getEmail()#">,
					<cfqueryparam cfsqltype="varchar" value='#variables.configuration.get('encryptKey')#'>
				)::varchar,
				status_id = <cfqueryparam cfsqltype="varchar" value="#arguments.account.getStatus().getId()#">,
				id_utente_verticale = <cfqueryparam cfsqltype="Integer" value="#arguments.account.getIdUtenteVerticale()#">,
				id_agente_verticale = <cfqueryparam cfsqltype="Integer" value="#arguments.account.getIdAgenteVerticale()#">
			WHERE
				account_id = <cfqueryparam cfsqltype="Other" value="#arguments.account.getId()#">
		</cfquery>

		<cfreturn arguments.account.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="lineId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				membership.accounts
			WHERE
				account_id = <cfqueryparam cfsqltype="Other" value="#arguments.lineId#">
			RETURNING account_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

	<cffunction name="updatePassword" output="No" returntype="Boolean">

		<cfargument name="accountId" required="Yes" type="String">
		<cfargument name="pwd" required="Yes" type="String">

		<cfquery name="local.q" datasource="apirone">
			UPDATE membership.accounts
			SET
				pwd = <cfqueryparam cfsqltype="varchar" value="#trim(arguments.pwd)#">
			WHERE
				account_id = <cfqueryparam cfsqltype="Other" value="#arguments.accountId#">
		</cfquery>

		<cfreturn true>

	</cffunction>

	<cffunction name="storeResetToken" output="No" returntype="void">
		<cfargument name="accountId"  type="String" required="true">
		<cfargument name="hashedToken" type="String" required="true">
		<cfargument name="expiresAt"  type="String" required="true">

		<cfquery datasource="apirone">
			UPDATE membership.accounts
			SET
				reset_token            = <cfqueryparam cfsqltype="varchar"   value="#arguments.hashedToken#">,
				reset_token_expires_at = <cfqueryparam cfsqltype="timestamp" value="#arguments.expiresAt#">
			WHERE
				account_id = <cfqueryparam cfsqltype="other" value="#arguments.accountId#">
		</cfquery>
	</cffunction>

	<cffunction name="clearResetToken" output="No" returntype="void">
		<cfargument name="accountId" type="String" required="true">

		<cfquery datasource="apirone">
			UPDATE membership.accounts
			SET
				reset_token            = NULL,
				reset_token_expires_at = NULL
			WHERE
				account_id = <cfqueryparam cfsqltype="other" value="#arguments.accountId#">
		</cfquery>
	</cffunction>

	<cffunction name="findByResetToken" returntype="Query">
		<cfargument name="hashedToken" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				account_id::varchar,
				pgp_sym_decrypt(
					email::bytea,
					<cfqueryparam cfsqltype="varchar" value="#variables.configuration.get('encryptKey')#">
				) AS email
			FROM membership.accounts
			WHERE
				reset_token            = <cfqueryparam cfsqltype="varchar" value="#arguments.hashedToken#">
				AND reset_token_expires_at > NOW()
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="updateLastLoggedUserId" output="No" returntype="Boolean">

		<cfargument name="accountId" required="Yes" type="String">
		<cfargument name="userId" required="Yes" type="String">

		<cfquery name="local.q" datasource="apirone">
			UPDATE membership.accounts
			SET
				last_logged_user_id = <cfqueryparam cfsqltype="Other" value="#trim(arguments.userId)#">
			WHERE
				account_id = <cfqueryparam cfsqltype="Other" value="#arguments.accountId#">
		</cfquery>

		<cfreturn true>

	</cffunction>

	<!---
		Recupera in batch più account dato un array di ID.
	--->
	<cffunction name="readByIds" returntype="Query" access="public">
		<cfargument name="ids" type="Array" required="true">

		<cfset var idsList = ArrayToList(arguments.ids)>

		<cfquery name="local.q" datasource="apirone">
			SELECT
				pgp_sym_decrypt(
					email::bytea,
					<cfqueryparam cfsqltype="varchar" value="#variables.configuration.get('encryptKey')#">
				) AS email,
				account_id::varchar,
				*
			FROM membership.accounts
			WHERE account_id = ANY(
				ARRAY[<cfqueryparam value="#idsList#" list="true" cfsqltype="varchar">]::uuid[]
			)
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>
