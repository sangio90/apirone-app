<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="quotationStatusHistoryId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_status_history_id,
				quotation_id::varchar,
				status_id::varchar,
				user_id::varchar,
				*
			FROM quotation_status_history
			WHERE quotation_status_history_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationStatusHistoryId#">
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationId" type="String" required="false">
		<cfargument name="userId" type="String" required="false">
		<cfargument name="statusId" type="String" required="false">
        <cfargument name="from" type="Date" required="false">
        <cfargument name="to" type="Date" required="false">
		<cfargument name="orderBy" type="String" required="true" default="created_at desc">
		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_status_history_id,
				quotation_id::varchar,
				status_id::varchar,
				user_id::varchar,
				COUNT(quotation_status_history_id) OVER() AS total
			FROM
				quotation_status_history
			WHERE 1=1
				<cfif !IsNull( arguments.quotationId )>
					AND quotation_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.userId )>
					AND user_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.userId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.statusId )>
					AND status_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.statusId#">
				</cfif>

				<cfif !isNull( arguments.from )>
					AND created_at >= <cfqueryparam value="#arguments.from#" cfsqltype="Date">
				</cfif>

				<cfif !isNull( arguments.from )>
					AND created_at <= <cfqueryparam value="#arguments.to#" cfsqltype="Date">
				</cfif>
			ORDER BY
				#super.sanitizeSQL( arguments.orderBy )#

			<cfif arguments.limit GT 0>
				LIMIT <cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET <cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="quotationStatusHistory" type="com.apirone.core.model.bean.QuotationStatusHistory" required="true">
		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_status_history (
				quotation_id,
				status_id,
				user_id
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationStatusHistory.getQuotationId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationStatusHistory.getStatus().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationStatusHistory.getUser().getId()#">::uuid
			)
			RETURNING quotation_status_history_id
		</cfquery>
		<cfreturn local.q.quotation_status_history_id>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="quotationStatusHistory" type="com.apirone.core.model.bean.QuotationStatusHistory" required="true">
		<cfquery name="local.q" datasource="apirone">
			UPDATE quotation_status_history
			SET
				quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationStatusHistory.getQuotationId()#">::uuid,
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationStatusHistory.getStatus().getId()#">,
				user_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationStatusHistory.getUser().getId()#">::uuid,
				updated_at = now()
			WHERE
				quotation_status_history_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationStatusHistory.getId()#">
		</cfquery>
		<cfreturn arguments.quotationStatusHistory.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="quotationStatusHistoryId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM
				quotation_status_history
			WHERE
				quotation_status_history_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationStatusHistoryId#">
		</cfquery>
		<cfreturn true>
	</cffunction>
</cfcomponent>
