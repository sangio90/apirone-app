<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="statusId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM statuses
			WHERE status_id = <cfqueryparam cfsqltype="varchar" value="#arguments.statusId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction returntype="Query" name="find">

		<cfargument name="entityId" required="false" type="String">
		<cfargument name="orderBy" required="false" type="String" default="orderby">
        
        <cfquery name="local.q" datasource="apirone">
			SELECT
				status_id,
				COUNT(status_id) OVER() AS total
			FROM
                statuses
			WHERE 1=1
                
            <cfif !IsNull(arguments.entityId)>
				AND jsonb_exists( entities, <cfqueryparam value="#UCase( arguments.entityId )#" cfsqltype="Varchar"> )
			</cfif>

			ORDER BY 
				#super.sanitizeSQL( arguments.orderby )#
		</cfquery>

		<cfreturn local.q>

	</cffunction>

</cfcomponent>