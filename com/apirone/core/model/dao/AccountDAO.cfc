<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	
	<cfproperty name="Configuration" type="com.apirone.core.model.bean.Configuration"/>

	<cffunction name="read">

		<cfargument name="accountId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
			 	account_id,
				api_key,
				status_id,
				pwd,
				role_id,
				lang_id,
				pgp_sym_decrypt(
					login::bytea,
					<cfqueryparam cfsqltype="varchar" value="#variables.configuration.get('encryptKey')#">
				) AS login
			FROM 
				accounts
			WHERE 
				account_id = <cfqueryparam cfsqltype="varchar" value="#arguments.accountId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="search">

		<cfargument name="email" type="String">
		<cfargument name="login" type="String">
		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone">
			SELECT 
				account_id,
				COUNT(account_id) OVER() AS total
			FROM 
				accounts
			WHERE 
				<cfif !isNull( arguments.login )>
					pgp_sym_decrypt(login::bytea, <cfqueryparam cfsqltype="varchar" value="#variables.configuration.get('encryptKey')#">) = <cfqueryparam cfsqltype="varchar" value="#arguments.login#">
				</cfif>
				<cfif !isNull( arguments.email )>
					pgp_sym_decrypt(login::bytea, <cfqueryparam cfsqltype="varchar" value="#variables.configuration.get('encryptKey')#">) = <cfqueryparam cfsqltype="varchar" value="#arguments.email#">
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
				login,
				api_key
			)
			VALUES (
				pgp_sym_encrypt(
					<cfqueryparam cfsqltype="varchar" value="#arguments.account.getLogin()#">, 
					<cfqueryparam cfsqltype="varchar" value='#variables.configuration.get('encryptKey')#'>
				)::varchar,
				<cfqueryparam cfsqltype="varchar" value="#arguments.account.getApiKey()#">
			) RETURNING account_id
		</cfquery>
	
		<cfreturn q.account_id>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">

		<cfargument name="accountId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM accounts 
			WHERE
				account_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.accountId#">
		</cfquery>

		<cfreturn true>
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