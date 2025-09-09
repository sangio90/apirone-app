<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="reportId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				reports
			WHERE
				report_id = <cfqueryparam cfsqltype="Integer" value="#arguments.reportId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="search">
		<cfargument name="str" type="String">
		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				report_id,
				COUNT(report_id) OVER() AS total
			FROM
				reports
			WHERE 1=1
			ORDER BY report_id
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
		<cfargument name="report" type="com.apirone.core.model.bean.Report" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO reports (
			)
			VALUES (
			) RETURNING report_id
		</cfquery>

		<cfreturn q.report_id>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="reportId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM reports
			WHERE
				report_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.reportId#">
		</cfquery>

		<cfreturn true>
	</cffunction>
</cfcomponent>
