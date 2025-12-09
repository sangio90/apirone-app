<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="quotationSerial" type="String" required="true">

		<cfquery name="local.q" datasource="verticaleExport">
			SELECT
				TOP 1 *
			FROM ORDINI_APIR
			WHERE MMSERIAL = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationSerial#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>
	
	<cffunction name="readRow" returntype="Query">
		<cfargument name="quotationSerial" type="String" required="true">
		<cfargument name="rowNumber" type="Numeric" required="true">

		<cfquery name="local.q" datasource="verticaleExport">
			SELECT
				*
			FROM ORDINI_APIR
			WHERE MMSERIAL = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationSerial#"> AND CPROWNUM = <cfqueryparam cfsqltype="Integer" value="#arguments.rowNumber#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">

		<cfargument name="str" type="String" required="false">
		<cfargument name ="orderBy" type="String" required="true" default ="MMDATEVA">

		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">

		<cfquery name="local.q" datasource="verticaleExport" result="result">
			WITH paging AS (
				SELECT
					MMSERIAL,
					COUNT( MMSERIAL ) OVER() AS total
				FROM ORDINI_APIR
				WHERE 1=1

				<cfif !IsNull( arguments.str )>
					AND LOWER(CFDESCR1) LIKE LOWER(<cfqueryparam cfsqltype="VARCHAR" value="%#arguments.str#%">)
				</cfif>

				ORDER BY
					MMSERIAL
				<!--- GROUP BY MMSERIAL ---->

				<cfif arguments.limit GT 0>
					OFFSET <cfqueryparam value="#arguments.offset#" cfsqltype="integer"> ROWS 
					FETCH NEXT <cfqueryparam value="#arguments.limit#" cfsqltype="integer"> ROWS ONLY
				</cfif>
			)
			SELECT
				p.MMSERIAL,
				(SELECT COUNT(DISTINCT MMSERIAL) FROM ORDINI_APIR WHERE 1 = 1) AS total
			FROM
				paging p;			
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="findRows" returntype="Query">
		<cfargument name="quotationSerial" type="String" required="false">

		<cfargument
			name    ="orderBy"
			type    ="String"
			required="true"
			default ="CPROWNUM"
		>

		<cfquery name="local.q" datasource="verticaleExport" result="result">
			SELECT
				MMSERIAL,
				CPROWNUM,
				COUNT( MMSERIAL ) OVER() AS total
			FROM ORDINI_APIR
			WHERE LOWER(MMSERIAL) LIKE LOWER(<cfqueryparam cfsqltype="VARCHAR" value="%#arguments.quotationSerial#%">)

			ORDER BY
				#super.sanitizeSQL( arguments.orderby )#
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="quotationSerial" type="String" required="true">

		<cfquery name="local.q" datasource="verticaleExport">
			DELETE FROM ORDINI_APIR
			WHERE MMSERIAL = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationSerial#">
		</cfquery>

		<cfreturn true>
	</cffunction>

	<cffunction name="deleteRow" returntype="Boolean">
		<cfargument name="quotationSerial" type="String" required="true">
		<cfargument name="rowNumber" type="Numeric" required="true">

		<cfquery name="local.q" datasource="verticaleExport">
			DELETE FROM ORDINI_APIR
			WHERE MMSERIAL = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationSerial#"> AND
				CPROWNUM = <cfqueryparam cfsqltype="INTEGER" value="#arguments.rowNumber#">
		</cfquery>

		<cfreturn true>
	</cffunction>
</cfcomponent>
