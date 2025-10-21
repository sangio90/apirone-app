<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="countryId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				country_id::varchar,
				*
			FROM countries
			WHERE 
				country_id = <cfqueryparam cfsqltype="varchar" value="#arguments.countryId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="readByCode" returntype="Query">
		<cfargument name="code" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				*
			FROM
				countries
			WHERE
				code = <cfqueryparam cfsqltype="varchar" value="#arguments.code#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction returntype="Query" name="find">
		<cfargument name="str" type="String">
		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="langId" type="String" default="IT">
		<cfargument name="orderby" required="true" type="String" default="countries.code asc">

        <cfquery name="local.q" datasource="apirone" result="result">
			SELECT DISTINCT
				<cfif arguments.orderBy CONTAINS "texts.text">
					texts.text,
				</cfif>
				country_id::varchar,
				countries.code,
				COUNT(country_id) OVER() AS total
			FROM
				countries
					INNER JOIN texts USING ( country_id )
			WHERE 1=1
                
				<cfif !IsNull( arguments.langId )>
					AND texts.lang_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.langId#">
				</cfif>

				<cfif Len( trim( arguments.str ) )>
					AND (
						countries.code ILIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="Varchar">
						OR texts.text ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
					)
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

	<cffunction name="insert" returntype="String">
		<cfargument name="country" type="com.apirone.core.model.bean.Country" required="true">
		<!--- <cfdump var="#arguments.country.getNameItem().getName()#"><cfabort> --->
		<cfquery name="local.q" datasource="apirone">
			INSERT INTO countries (
				code,
				country
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.country.getCode()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.country.getNameItem().getName()#">
			) RETURNING country_id
		</cfquery>

		<cfreturn local.q.country_id.toString()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="countryId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				countries
			WHERE
				country_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.countryId#">::uuid
			RETURNING country_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

</cfcomponent>