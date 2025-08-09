<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="auditEntryId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				audit_logs
			WHERE
				audit_log_id = <cfqueryparam cfsqltype="Integer" value="#arguments.auditEntryId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String">
		<cfargument name="actionId" type="String">
		<cfargument name="entityId" type="String">
		<cfargument name="fromDate" type="Date">
		<cfargument name="toDate" type="Date">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="created_at DESC">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				audit_log_id,
				COUNT(audit_log_id) OVER() AS total
			FROM
				audit_logs
			WHERE 1=1

				<cfif !IsNull( arguments.actionId )>
					AND action = <cfqueryparam cfsqltype="varchar" value="#arguments.actionId#">
				</cfif>

				<cfif !IsNull( arguments.entityId )>
					AND entity = <cfqueryparam cfsqltype="varchar" value="#arguments.entityId#">
				</cfif>

				<cfif !IsNull( arguments.fromDate )>
					AND created_at >= <cfqueryparam cfsqltype="timestamp" value="#arguments.fromDate#">
				</cfif>

				<cfif !IsNull( arguments.toDate )>
					AND created_at <= <cfqueryparam cfsqltype="timestamp" value="#arguments.toDate#">
				</cfif>

				<cfif !IsNull( arguments.str )>
					AND message ILIKE <cfqueryparam cfsqltype="varchar" value="%#arguments.str#%">
				</cfif>

			ORDER BY
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GT 0>
				LIMIT
					<cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET
					<cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>

