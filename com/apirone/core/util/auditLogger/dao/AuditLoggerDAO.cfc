<cfcomponent accessors="true">
	<cfproperty name="datasource" type="String">

	<cffunction name="insert">
		<cfargument name="LogEntry" type="AuditLogger.bean.LogEntry" required="true">

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
				<cfqueryparam value="#arguments.LogEntry.getMessage()#" cfsqltype="varchar">,
				<cfqueryparam value="#arguments.LogEntry.getEntity()#" cfsqltype="varchar">,
				<cfqueryparam value="#arguments.LogEntry.getAction()#" cfsqltype="varchar">,
				<cfqueryparam value="#arguments.LogEntry.getSeverity()#" cfsqltype="varchar">,
				<cfqueryparam value="#arguments.LogEntry.getAccountId()#" cfsqltype="varchar">::uuid,
				<cfqueryparam value="#arguments.LogEntry.getCreatedAt()#" cfsqltype="timestamp">,
				<cfqueryparam value="#arguments.LogEntry.getIpAddress()#" cfsqltype="varchar">,
				<cfqueryparam value="#arguments.LogEntry.getUserAgent()#" cfsqltype="varchar">,
				<cfqueryparam value="#arguments.LogEntry.getPayload()#" cfsqltype="other">
			) RETURNING audit_log_id
		</cfquery>
	</cffunction>
</cfcomponent>
