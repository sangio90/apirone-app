<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cfproperty name="Configuration" inject="bean:Configuration"/>

	<cffunction name="read" returntype="Query">

		<cfargument name="userId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				user_id::varchar,
				*
			FROM
				membership.users
			WHERE
				user_id = <cfqueryparam cfsqltype="Other" value="#arguments.userId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<!---
		Recupera in batch più record dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query">
		<cfargument name="ids" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.ids )>

		<cfquery name="local.q" datasource="apirone">
			SELECT
				user_id::varchar,
				*
			FROM membership.users
			WHERE user_id = ANY( <cfqueryparam value="#idsList#" list="false" cfsqltype="varchar">::uuid[] )
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">

		<cfargument name="str" type="String">
		<cfargument name="roleId" type="String">
		<cfargument name="langId" type="String">
		<cfargument name="statusId" type="String">
		<cfargument name="accountId" type="String">
		<cfargument name="roleTypeId" type="String">
		<cfargument name="hasUtenteVerticale" type="Boolean">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				user_id::varchar,
				COUNT(user_id) OVER() AS total
			FROM
				membership.users
					INNER JOIN membership.roles USING ( role_id )
			WHERE 1=1

				<cfif !IsNull( arguments.str )>
					AND user_name ILIKE <cfqueryparam cfsqltype="varchar" value="%#arguments.str#%">
				</cfif>

				<cfif !IsNull( arguments.statusId )>
					AND status_id = <cfqueryparam cfsqltype="varchar" value="#arguments.statusId#">
				</cfif>

				<cfif !IsNull( arguments.langId )>
					AND lang_id = <cfqueryparam cfsqltype="varchar" value="#arguments.langId#">
				</cfif>

				<cfif !IsNull( arguments.roleId )>
					AND role_id = <cfqueryparam cfsqltype="varchar" value="#arguments.roleId#">
				</cfif>

				<cfif !IsNull( arguments.roleTypeId )>
					AND role_type_id = <cfqueryparam cfsqltype="varchar" value="#arguments.roleTypeId#">
				</cfif>

				<cfif !IsNull( arguments.accountId )>
					AND account_id = <cfqueryparam cfsqltype="Other" value="#arguments.accountId#">
				</cfif>

				<cfif !IsNull( arguments.hasUtenteVerticale ) AND arguments.hasUtenteVerticale>
					AND EXISTS (
						SELECT 1 FROM membership.accounts
						WHERE accounts.account_id = users.account_id
						AND accounts.id_utente_verticale IS NOT NULL
					)
				</cfif>

			ORDER BY
				serial DESC
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

		<cfargument name="user" type="com.apirone.core.model.bean.User" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO membership.users (
				user_name,
				status_id,
				role_id,
				phone,
				account_id,
				lang_id
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.user.getName()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.user.getStatus().getId()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.user.getRole().getId()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.user.getPhone()#">,
				<cfqueryparam cfsqltype="Other" value="#arguments.user.getAccount().getId()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.user.getLang().getId()#">
			) RETURNING user_id::varchar
		</cfquery>

		<cfreturn q.user_id>
	</cffunction>

	<cffunction name="update" returntype="String">

		<cfargument name="user" type="com.apirone.core.model.bean.User" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE membership.users
			SET
				user_name = <cfqueryparam cfsqltype="varchar" value="#arguments.user.getName()#">,
				phone = <cfqueryparam cfsqltype="varchar" value="#arguments.user.getPhone()#">,
				status_id = <cfqueryparam cfsqltype="varchar" value="#arguments.user.getStatus().getId()#">,
				role_id = <cfqueryparam cfsqltype="varchar" value="#arguments.user.getRole().getId()#">,
				lang_id = <cfqueryparam cfsqltype="varchar" value="#arguments.user.getLang().getId()#">
			WHERE
				user_id = <cfqueryparam cfsqltype="Other" value="#arguments.user.getId()#">
		</cfquery>

		<cfreturn arguments.user.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="userId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				membership.users
			WHERE
				user_id = <cfqueryparam cfsqltype="Other" value="#arguments.userId#">
			RETURNING user_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

</cfcomponent>
