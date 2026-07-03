<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="fontId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				font_family_id,
				*
			FROM
				fonts
			WHERE
				font_id = <cfqueryparam cfsqltype="Integer" value="#arguments.fontId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="readByCode" output="false">
		<cfargument name="code" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				font_id, code
			FROM
				fonts
			WHERE
				code = <cfqueryparam cfsqltype="varchar" value="#arguments.code#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction returntype="Query" name="find">
		<cfargument name="str" type="String">
		<cfargument name="fontFamilyId" type="Numeric">

		<cfargument name="orderby" required="true" type="String" default="font_id desc">
		<cfargument name="limit" required="true" type="Numeric" default="15">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				font_id::varchar,
				code,
				directory,
				height_width_ratio,
				font_family_id,
				created_at,
				COUNT(font_id) OVER() AS total
			FROM
				fonts
			WHERE 1=1
				<cfif !IsNull( arguments.str )>
					AND code ILIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="varchar">
				</cfif>
				<cfif !IsNull( arguments.fontFamilyId )>
					AND font_family_id = <cfqueryparam value="%#arguments.fontFamilyId#%" cfsqltype="Numeric">
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

	<!---
		Recupera in batch più record dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query">
		<cfargument name="ids" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.ids )>

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM fonts
			WHERE font_id IN (
				<cfqueryparam value="#idsList#" list="true" cfsqltype="integer">
			)
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="Numeric">
		<cfargument name="font" type="com.apirone.core.model.bean.Font" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO fonts (
				code,
				directory,
				height_width_ratio,
				font_family_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.font.getCode()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.font.getDirectory()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.font.getHeightWidthRatio()#">,
				<cfif !IsNull( arguments.font.getFontFamily() )>
					<cfqueryparam cfsqltype="Numeric" value="#arguments.font.getFontFamily().getId()#">
				<cfelse>
					NULL
				</cfif>
			) RETURNING font_id
		</cfquery>

		<cfreturn local.q.font_id>
	</cffunction>

	<cffunction name="update" returntype="Numeric">
		<cfargument name="font" type="com.apirone.core.model.bean.Font" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				fonts
			SET
				code = <cfqueryparam cfsqltype="Varchar" value="#arguments.font.getCode()#">,
				directory = <cfqueryparam cfsqltype="Varchar" value="#arguments.font.getDirectory()#">,
				height_width_ratio = <cfqueryparam cfsqltype="Numeric" value="#arguments.font.getHeightWidthRatio()#">
				<cfif !IsNull( arguments.font.getFontFamily() )>
					,
					font_family_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.font.getFontFamily().getId()#">
				</cfif>
			WHERE
				font_id = <cfqueryparam cfsqltype="Integer" value="#arguments.font.getId()#">
		</cfquery>

		<cfreturn arguments.font.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="fontId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				fonts
			WHERE
				font_id = <cfqueryparam cfsqltype="Integer" value="#arguments.fontId#">
			RETURNING font_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>
</cfcomponent>
