<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read" returntype="Query">

		<cfargument name="textId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM texts
			WHERE text_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.textId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="find" returntype="Query">

		<cfargument name="statusId" type="String">
		<cfargument name="str" type="String">
		<cfargument name="langId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="langs.orderby">

		<cfquery name="local.q" datasource="apirone">
			SELECT
             text_id, 
                COUNT text_id OVER() AS total
			FROM texts
                INNER JOIN langs USING ( lang_id )
			WHERE 1=1

			<cfif !isNull( arguments.statusId ) >
				AND status_id = <cfqueryparam cfsqltype="varchar" value="#arguments.statusId#">
			</cfif>

			<cfif !isNull( arguments.str ) >
				AND text ILIKE <cfqueryparam cfsqltype="varchar" value="#arguments.str#%">
			</cfif>

			<cfif !isNull( arguments.langId ) >
				AND lang_id = <cfqueryparam cfsqltype="varchar" value="#arguments.langId#">
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