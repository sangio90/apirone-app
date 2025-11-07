<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="exportCodeRawValueId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
			    export_code_raw_value_id,
			    export_code_id,
				raw_value_id,
				*
			FROM
				export_code_raw_values
			WHERE
				export_code_raw_value_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.exportCodeRawValueId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="exportCodeId" type="Numeric">
		<cfargument name="rawValueId" type="String">
		<cfargument name="str" type="String">

		<cfargument name="orderby" required="true" type="String" default="product.product_id">
		<cfargument name="limit" required="true" type="Numeric" default="15">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				export_code_raw_value_id,
				COUNT(export_code_raw_value_id) OVER() AS total
			FROM
				export_code_raw_values

			WHERE 1=1

				<cfif !IsNull( arguments.str )>
					AND suffix_code ILIKE <cfqueryparam cfsqltype="varchar" value="%#arguments.str#%">
				</cfif>

				<cfif !IsNull( arguments.exportCodeId )>
					AND export_code_id = <cfqueryparam cfsqltype="Integer" value="#arguments.exportCodeId#">
				</cfif>

				<cfif !IsNull( arguments.rawValueId )>
					AND raw_value_id = <cfqueryparam cfsqltype="Integer" value="#arguments.rawValueId#">
				</cfif>

			ORDER BY
				export_code_id ASC

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
		<cfargument name="exportCodeRawValue" type="com.apirone.core.model.bean.ExportCodeRawValue" required="true">
			
		<cfquery name="local.q" datasource="apirone">
			INSERT INTO export_code_raw_values (
				export_code_id,
				raw_value_id,
				important,
				suffix_code
			)
			VALUES (
				<cfqueryparam cfsqltype="Integer" value="#arguments.exportCodeRawValue.getExportCode().getId()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.exportCodeRawValue.getRawValue().getId()#">,
				<cfqueryparam cfsqltype="Boolean" value="#arguments.exportCodeRawValue.getImportant()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.exportCodeRawValue.getSuffixCode()#">,
			) RETURNING export_code_raw_value_id
		</cfquery>

		<cfreturn local.q.export_code_raw_value_id>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="exportCodeRawValue" type="com.apirone.core.model.bean.ExportCodeRawValue" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				export_code_raw_values
			SET
				export_code_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.exportCodeRawValue.getExportCode().getId()#">,
				raw_value_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.exportCodeRawValue.getRawValue().getId()#">,
				important = <cfqueryparam cfsqltype="Boolean" value="#arguments.exportCodeRawValue.getImportant()#">,
				suffix_code = <cfqueryparam cfsqltype="Varchar" value="#arguments.exportCodeRawValue.getSuffixCode()#">
			WHERE
				export_code_raw_value_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.exportCodeRawValue.getId()#">
		</cfquery>

		<cfreturn arguments.exportCodeRawValue.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="exportCodeRawValueId" type="Numeric">

		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM export_code_raw_values
			WHERE
				export_code_raw_value_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.exportCodeRawValueId#">
		</cfquery>

		<cfreturn true>
	</cffunction>
</cfcomponent>
