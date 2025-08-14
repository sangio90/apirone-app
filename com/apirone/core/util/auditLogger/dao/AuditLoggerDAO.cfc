<cfcomponent accessors="true">
	<cfproperty name="datasource" type="String">

	<cffunction name="insert">
		<cfargument name="auditEntry" type="AuditLogger.bean.AuditEntry" required="true">

		<cfquery datasource="#getDatasource()#">
			INSERT INTO audit_logs (
				message,
				entity,
				action,
				severity,
				account_id,
				created_at,
				ip_address,
				user_agent,
				payload
			)
			VALUES (
				<cfqueryparam value="#arguments.AuditEntry.getMessage()#" cfsqltype="varchar">,
				<cfqueryparam value="#arguments.AuditEntry.getEntity()#" cfsqltype="varchar">,
				<cfqueryparam value="#arguments.AuditEntry.getAction()#" cfsqltype="varchar">,
				<cfqueryparam value="#arguments.AuditEntry.getSeverity()#" cfsqltype="varchar">,
				<cfif arguments.AuditEntry.getAccountId() == "anonymous">
					NULL
				<cfelse>
					<cfqueryparam value="#arguments.AuditEntry.getAccountId()#" cfsqltype="varchar">::uuid
				</cfif>
				,
				<cfqueryparam value="#arguments.AuditEntry.getCreatedAt()#" cfsqltype="timestamp">,
				<cfqueryparam value="#arguments.AuditEntry.getIpAddress()#" cfsqltype="varchar">,
				<cfqueryparam value="#arguments.AuditEntry.getUserAgent()#" cfsqltype="varchar">,
				<cfif !IsNull( arguments.AuditEntry.getPayload() )>
					<cfqueryparam value="#arguments.AuditEntry.getPayload()#" cfsqltype="other">
				<cfelse>
					NULL
				</cfif>
			) RETURNING audit_log_id
		</cfquery>
	</cffunction>
</cfcomponent>
