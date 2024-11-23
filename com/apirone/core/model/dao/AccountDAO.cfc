<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	
	<cfproperty name="Configuration" type="com.apirone.core.model.bean.Configuration"/>

	<cffunction name="read" returntype="Query">

		<cfargument name="accountId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				pgp_sym_decrypt(
					email::bytea,
					<cfqueryparam cfsqltype="varchar" value="#variables.configuration.get('encryptKey')#">
				) AS email,
				*
			FROM 
				accounts
			WHERE 
				account_id = <cfqueryparam cfsqltype="varchar" value="#arguments.accountId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="readByEmail" returntype="Query">

		<cfargument name="email" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
			 	account_id,
				pgp_sym_decrypt(
					email::bytea,
					<cfqueryparam cfsqltype="varchar" value="#variables.configuration.get('encryptKey')#">
				) AS email
			FROM 
				accounts
			WHERE 
				pgp_sym_decrypt(email::bytea, <cfqueryparam cfsqltype="varchar" value="#variables.configuration.get("encryptKey")#">) = <cfqueryparam cfsqltype="varchar" value="#arguments.email#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="find" returntype="Query">

		<cfargument name="email" type="String">
		<cfargument name="str" type="String">
		<cfargument name="roleId" type="String">
		<cfargument name="langId" type="String">
		<cfargument name="statusId" type="String">
		
		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone">
			SELECT 
				account_id,
				COUNT(account_id) OVER() AS total
			FROM 
				accounts
			WHERE 1=1

				<cfif !IsNull( arguments.email )>
					AND pgp_sym_decrypt(email::bytea, <cfqueryparam cfsqltype="varchar" value="#variables.configuration.get("encryptKey")#">) = <cfqueryparam cfsqltype="varchar" value="#arguments.email#">
				</cfif>

				<cfif !IsNull( arguments.str )>
					AND (
						pgp_sym_decrypt(email::bytea, <cfqueryparam cfsqltype="varchar" value="#variables.configuration.get("encryptKey")#">) 
						ILIKE <cfqueryparam cfsqltype="varchar" value="#arguments.str#%">
						OR 
						account_id::varchar ILIKE <cfqueryparam cfsqltype="varchar" value="%#arguments.str#">
					)
				</cfif>

				<cfif !IsNull( arguments.statusId )>
					AND status_id ILIKE <cfqueryparam cfsqltype="varchar" value="#arguments.statusId#">
				</cfif>

				<cfif !IsNull( arguments.langId )>
					AND lang_id ILIKE <cfqueryparam cfsqltype="varchar" value="#arguments.langId#">
				</cfif>

				<cfif !IsNull( arguments.roleId )>
					AND role_id ILIKE <cfqueryparam cfsqltype="varchar" value="#arguments.roleId#">
				</cfif>

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
			INSERT INTO accounts (
				email,
				api_key,
				status_id,
				role_id
			)
			VALUES (
				pgp_sym_encrypt(
					<cfqueryparam cfsqltype="varchar" value="#arguments.account.getEmail()#">, 
					<cfqueryparam cfsqltype="varchar" value='#variables.configuration.get('encryptKey')#'>
				)::varchar,
				<cfqueryparam cfsqltype="varchar" value="#arguments.account.getApiKey()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.account.getStatus().getId()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.account.getRole().getId()#">
			) RETURNING account_id
		</cfquery>
	
		<cfreturn q.account_id>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="lineId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				accounts
			WHERE
				account_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
			RETURNING account_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

	<cffunction name="updatePassword" output="No" returntype="Boolean">

		<cfargument name="accountId" required="Yes" type="String">
		<cfargument name="pwd" required="Yes" type="String">

		<cfquery name="local.q" datasource="apirone">
			UPDATE accounts
			SET 
				pwd = <cfqueryparam cfsqltype="varchar" value="#trim(arguments.pwd)#">
			WHERE 
				account_id = <cfqueryparam cfsqltype="varchar" value="#arguments.accountId#">::uuid
		</cfquery>
		
		<cfreturn true>

	</cffunction>

</cfcomponent>