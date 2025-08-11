<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction returntype="Query" name="read">
		<cfargument name="textKindId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT text_kind_id, *
			FROM text_kinds
			WHERE text_kind_id = <cfqueryparam cfsqltype="varchar" value="#arguments.textKindId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="limit" required="true" type="Numeric" default="50">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				text_kind_id,
				COUNT(text_kind_id) OVER() AS total
			FROM
				text_kinds
			WHERE 1=1

			<cfif arguments.limit GT 0>
				LIMIT
					<cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET
					<cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>

			ORDER BY
				text_kind_id
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>
