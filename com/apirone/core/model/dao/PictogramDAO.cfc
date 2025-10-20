<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="pictogramId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				*
			FROM
				pictograms
			WHERE
				pictogram_id = <cfqueryparam cfsqltype="Integer" value="#arguments.pictogramId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="readByCodeAndFontFamily" output="false">
		<cfargument name="code" type="String" required="true">
		<cfargument name="fontFamilyId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				pictogram_id,
				code
			FROM
				pictograms
			WHERE
				code = <cfqueryparam cfsqltype="varchar" value="#arguments.code#"> AND
				font_family_id = <cfqueryparam cfsqltype="Integer" value="#arguments.fontFamilyId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction returntype="Query" name="find">
		<cfargument name="fontFamilyId" type="Numeric">
		<cfargument name="str" type="String">

		<cfargument name="orderby" required="true" type="String" default="pictogram_id desc">
		<cfargument name="limit" required="true" type="Numeric" default="15">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				pictogram_id,
				COUNT(pictogram_id) OVER() AS total
			FROM
				pictograms
			WHERE 1=1
				<cfif !IsNull( arguments.str )>
					AND code ILIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="varchar">
				</cfif>
				<cfif !IsNull( arguments.fontFamilyId )>
					AND font_family_id = <cfqueryparam cfsqltype="Integer" value="#arguments.fontFamilyId#">
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
		<cfargument name="pictogram" type="com.apirone.core.model.bean.Pictogram" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO pictograms (
				code,
				font_family_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.pictogram.getCode()#">,
				<cfif !IsNull( arguments.pictogram.getFontFamily() )>
					<cfqueryparam cfsqltype="Integer" value="#arguments.pictogram?.getFontFamily()?.getId()#">
				<cfelse>
					NULL
				</cfif>
			) RETURNING pictogram_id
		</cfquery>

		<cfreturn local.q.pictogram_id>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="pictogramId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				pictograms
			WHERE
				pictogram_id = <cfqueryparam cfsqltype="Integer" value="#arguments.pictogramId#">
			RETURNING pictogram_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>
</cfcomponent>
