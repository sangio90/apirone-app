cfabort
<cfabort>

<cfquery name="j" datasource="apirone">
    SELECT *
    FROM accounts
    ORDER BY account_id
</cfquery>

<cfloop query="j">

	<cfset roles = DESerializeJSON(j.roles.toString())>

	<cfloop array="#roles#" index="roleId">

		<cfquery name="k" datasource="apirone">
			INSERT INTO users (
				"user", -- reserved word
				role_id,
				status_id,
				lang_id,
				account_id,
				phone,
				created_at
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#j.account#">,
				<cfqueryparam cfsqltype="Varchar" value="#roleId#">,
				<cfqueryparam cfsqltype="Varchar" value="#j.status_id#">,
				<cfqueryparam cfsqltype="Varchar" value="#j.lang_id#">,
				<cfqueryparam cfsqltype="Other" value="#j.account_id#">,
				<cfqueryparam cfsqltype="Varchar" value="#j.phone#">,
				<cfqueryparam cfsqltype="Timestamp" value="#j.created_at#">
			)
		</cfquery>

	</cfloop>


</cfloop>
