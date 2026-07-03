<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="searchTermId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *, product_id::varchar
			FROM
				utils.search_terms
			WHERE
				search_term_id = <cfqueryparam cfsqltype="Integer" value="#arguments.searchTermId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="search_term">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				search_term_id,
				search_term,
				created_at,
				product_id::varchar,
				COUNT(search_term_id) OVER() AS total
			FROM
				utils.search_terms
			WHERE 1=1

				<cfif !IsNull( arguments.str )>
					<cfloop list="#arguments.str#" item="item" delimiters=" ">
						AND
						search_term ILIKE <cfqueryparam cfsqltype="Varchar" value="%#item#%">
					</cfloop>
				</cfif>

			ORDER BY
				search_term

			<cfif arguments.limit GT 0>
				LIMIT
					<cfqueryparam value="#arguments.limit#" cfsqltype="Integer">
				OFFSET
					<cfqueryparam value="#arguments.offset#" cfsqltype="Integer">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Recupera in batch più record dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query" access="public">
		<cfargument name="ids" type="Array" required="true">

		<cfreturn super.$readByIdsInteger(
			table   = "utils.search_terms",
			pkColumn = "search_term_id",
			ids     = arguments.ids
		)>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="searchTermId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				utils.search_terms
			WHERE
				search_term_id = <cfqueryparam cfsqltype="Integer" value="#arguments.searchTermId#">
			RETURNING search_term_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>
</cfcomponent>

