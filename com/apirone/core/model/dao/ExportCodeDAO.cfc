<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="exportCodeId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				*
			FROM
				export_codes
			WHERE
				export_code_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.exportCodeId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="max" returntype="Numeric">
		<cfargument name="exportCode" type="String">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT COALESCE(MAX(counter::INT), 0) AS max_counter
			FROM export_codes
			WHERE export_code = <cfqueryparam value="#arguments.exportCode#" cfsqltype="Varchar">
		</cfquery>
		
		<cfreturn local.q.max_counter>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String">

		<cfargument name="orderby" required="true" type="String" default="product.product_id">
		<cfargument name="limit" required="true" type="Numeric" default="15">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				export_code_id,
				COUNT(export_code_id) OVER() AS total
			FROM
				export_codes
			WHERE 1=1
				<cfif !IsNull( arguments.str )>
					AND export_code ILIKE <cfqueryparam cfsqltype="varchar" value="%#arguments.str#%">
				</cfif>
			ORDER BY
				export_code ASC

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
		<cfargument name="exportCode" type="com.apirone.core.model.bean.ExportCode" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO export_codes (
				export_code,
				counter
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#Trim( arguments.exportCode.getName() )#">,
				<cfqueryparam cfsqltype="Varchar" value="#Trim( arguments.exportCode.getCounter() )#">
			) RETURNING export_code_id
		</cfquery>

		<cfreturn local.q.export_code_id>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="exportCode" type="com.apirone.core.model.bean.ExportCode" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				export_codes
			SET
				export_code = <cfqueryparam cfsqltype="Varchar" value="#Trim( arguments.exportCode.getName() )#">,
				counter = <cfqueryparam cfsqltype="Varchar" value="#Trim( arguments.exportCode.getCounter() )#">
			WHERE
				export_code_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.exportCode.getId()#">
		</cfquery>

		<cfreturn arguments.exportCode.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="exportCodeId" type="Numeric">

		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM export_codes
			WHERE
				export_code_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.exportCodeId#">
		</cfquery>

		<cfreturn true>
	</cffunction>
</cfcomponent>
