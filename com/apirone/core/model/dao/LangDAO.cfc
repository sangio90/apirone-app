<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="langId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM langs
			WHERE lang_id = <cfqueryparam cfsqltype="varchar" value="#arguments.langId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction returntype="Query" name="find">

		<cfargument name="statusId" type="String">
		<cfargument name="str" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="orderby">

		<cfquery name="local.q" datasource="apirone">
			SELECT
                lang_id, 
                COUNT(lang_id) OVER() AS total
			FROM langs
			WHERE 1=1

			<cfif !isNull( arguments.statusId ) >
				AND status_id = <cfqueryparam cfsqltype="varchar" value="#arguments.statusId#">
			</cfif>

			<cfif !isNull( arguments.str ) >
				AND lang ILIKE <cfqueryparam cfsqltype="varchar" value="#arguments.str#%">
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