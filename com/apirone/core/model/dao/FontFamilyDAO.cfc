<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="fontFamilyId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				*
			FROM
				font_families
			WHERE
				font_family_id = <cfqueryparam cfsqltype="Integer" value="#arguments.fontFamilyId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="readByCode" output="false">
		<cfargument name="code" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				font_family_id, code
			FROM
				font_families
			WHERE
				code = <cfqueryparam cfsqltype="varchar" value="#arguments.code#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction returntype="Query" name="find">
		<cfargument name="str" type="String">

		<cfargument name="orderby" required="true" type="String" default="font_family_id desc">
		<cfargument name="limit" required="true" type="Numeric" default="15">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				font_family_id,
				COUNT(font_family_id) OVER() AS total
			FROM
				font_families
			WHERE 1=1
				<cfif !IsNull( arguments.str )>
					AND code ILIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="varchar">
					OR font_family ILIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="varchar">
				</cfif>
			ORDER BY
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GTE 0>
				LIMIT
					<cfqueryparam cfsqltype="integer" value="#arguments.limit#">
				OFFSET
					<cfqueryparam cfsqltype="integer" value="#arguments.offset#">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="Numeric">
		<cfargument name="fontFamily" type="com.apirone.core.model.bean.FontFamily" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO font_families (
				code,
				font_family
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.fontFamily.getCode()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.fontFamily.getName()#">
			) RETURNING font_family_id
		</cfquery>

		<cfreturn local.q.font_family_id>
	</cffunction>

	<cffunction name="update" returntype="Numeric">
		<cfargument name="fontFamily" type="com.apirone.core.model.bean.FontFamily" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				font_families
			SET
				code = <cfqueryparam cfsqltype="Varchar" value="#arguments.fontFamily.getCode()#">,
				font_family = <cfqueryparam cfsqltype="Varchar" value="#arguments.fontFamily.getName()#">
			WHERE
				font_family_id = <cfqueryparam cfsqltype="Integer" value="#arguments.fontFamily.getId()#">
		</cfquery>

		<cfreturn arguments.fontFamily.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="fontFamilyId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				font_families
			WHERE
				font_family_id = <cfqueryparam cfsqltype="Integer" value="#arguments.fontFamilyId#">
			RETURNING font_family_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>
</cfcomponent>
