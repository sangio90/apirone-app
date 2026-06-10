<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="key" type="String" required="true">

		<cfquery name="local.q" datasource="verticaleExport">
			SELECT
				*
			FROM ARTICO_APIR
			WHERE AR_CHIAVE = <cfqueryparam cfsqltype="Varchar" value="#arguments.key#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Recupera in batch più record dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query">
		<cfargument name="ids" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.ids )>

		<cfquery name="local.q" datasource="verticaleExport">
			SELECT
				*
			FROM ARTICO_APIR
			WHERE AR_CHIAVE IN ( <cfqueryparam value="#idsList#" list="true" cfsqltype="varchar"> )
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="readRow" returntype="Query">
		<cfargument name="key" type="String" required="true">
		<cfargument name="rowNumber" type="Numeric" required="true">

		<cfquery name="local.q" datasource="verticaleExport">
			SELECT
				*
			FROM DISBAS_APIR
			WHERE DS_CHIAVE = <cfqueryparam cfsqltype="Varchar" value="#arguments.key#"> AND CPROWNUM = <cfqueryparam cfsqltype="Integer" value="#arguments.rowNumber#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Recupera in batch tutte le righe di un articolo esportato, dato il DS_CHIAVE.
		Utilizzato dal Service corrispondente per caricare le righe in blocco.
	--->
	<cffunction name="readRowsByKey" returntype="Query">
		<cfargument name="key" type="String" required="true">

		<cfquery name="local.q" datasource="verticaleExport">
			SELECT
				*
			FROM DISBAS_APIR
			WHERE DS_CHIAVE = <cfqueryparam cfsqltype="Varchar" value="#arguments.key#">
			ORDER BY CPROWNUM
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String" required="false">

		<cfargument
			name    ="orderBy"
			type    ="String"
			required="true"
			default ="ARDATCAR"
		>

		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">

		<cfquery name="local.q" datasource="verticaleExport" result="result">
			SELECT
				AR_CHIAVE,
				COUNT( AR_CHIAVE ) OVER() AS total
			FROM ARTICO_APIR
			WHERE 1=1

			<cfif !IsNull( arguments.str )>
				AND LOWER(ARDESART) LIKE LOWER(<cfqueryparam cfsqltype="VARCHAR" value="%#arguments.str#%">)
			</cfif>

			ORDER BY
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GT 0>
				OFFSET <cfqueryparam value="#arguments.offset#" cfsqltype="integer"> ROWS
				FETCH NEXT <cfqueryparam value="#arguments.limit#" cfsqltype="integer"> ROWS ONLY
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="findRows" returntype="Query">
		<cfargument name="key" type="String" required="false">

		<cfargument
			name    ="orderBy"
			type    ="String"
			required="true"
			default ="CPROWNUM"
		>

		<cfquery name="local.q" datasource="verticaleExport" result="result">
			SELECT
				DS_CHIAVE,
				CPROWNUM,
				COUNT( DS_CHIAVE ) OVER() AS total
			FROM DISBAS_APIR
			WHERE LOWER(DS_CHIAVE) LIKE LOWER(<cfqueryparam cfsqltype="VARCHAR" value="%#arguments.key#%">)

			ORDER BY
				#super.sanitizeSQL( arguments.orderby )#
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="key" type="String" required="true">

		<cfquery name="local.q" datasource="verticaleExport">
			DELETE FROM DISBAS_APIR
			WHERE DS_CHIAVE = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.key#">
		</cfquery>

		<cfquery name="local.q" datasource="verticaleExport">
			DELETE FROM ARTICO_APIR
			WHERE AR_CHIAVE = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.key#">
		</cfquery>

		<cfreturn true>
	</cffunction>

	<cffunction name="deleteRow" returntype="Boolean">
		<cfargument name="key" type="String" required="true">
		<cfargument name="rowNumber" type="Numeric" required="true">

		<cfquery name="local.q" datasource="verticaleExport">
			DELETE FROM DISBAS_APIR
			WHERE DS_CHIAVE = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.key#"> AND
				CPROWNUM = <cfqueryparam cfsqltype="INTEGER" value="#arguments.rowNumber#">
		</cfquery>

		<cfreturn true>
	</cffunction>
</cfcomponent>
