<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="fontFamilySizeId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				*
			FROM
				font_family_sizes
			WHERE
				font_family_size_id = <cfqueryparam cfsqltype="Integer" value="#arguments.fontFamilySizeId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="readByFontFamily" output="false">
		<cfargument name="name" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				font_family_size_id, 
				font_families.font_family
			FROM
				font_family_sizes
					INNER JOIN font_families USING (font_family_id)
			WHERE
				font_families.font_family = <cfqueryparam cfsqltype="varchar" value="#arguments.name#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction returntype="Query" name="find">
		<cfargument name="str" type="String">
		<cfargument name="fontFamilyId" type="Numeric">

		<cfargument name="orderby" required="true" type="String" default="font_family_id desc">
		<cfargument name="limit" required="true" type="Numeric" default="15">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				font_family_size_id,
				COUNT(font_family_size_id) OVER() AS total
			FROM
				font_family_sizes
					INNER JOIN font_families USING (font_family_id)
			WHERE 1=1
				<cfif !IsNull( arguments.str )>
					AND font_families.font_family ILIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="varchar">
				</cfif>
				<cfif !IsNull( arguments.fontFamilyId )>
					AND font_family_id = <cfqueryparam value="#arguments.fontFamilyId#" cfsqltype="integer">
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
		<cfargument name="fontFamilySize" type="com.apirone.core.model.bean.FontFamilySize" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO font_family_sizes (
				font_family_id,
				font_family_size
			)
			VALUES (
				<cfqueryparam cfsqltype="Integer" value="#arguments.fontFamilySize.getFontFamily().getId()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.fontFamilySize.getName()#">
			) RETURNING font_family_size_id
		</cfquery>

		<cfreturn local.q.font_family_size_id>
	</cffunction>

	<cffunction name="update" returntype="Numeric">
		<cfargument name="fontFamilySize" type="com.apirone.core.model.bean.FontFamilySize" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				font_family_sizes
			SET
				font_family_size = <cfqueryparam cfsqltype="Integer" value="#arguments.fontFamilySize.getName()#">
			WHERE
				font_family_id = <cfqueryparam cfsqltype="Integer" value="#arguments.fontFamilySize.getId()#">
		</cfquery>

		<cfreturn arguments.fontFamilySize.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="fontFamilySizeId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				font_family_sizes
			WHERE
				font_family_size_id = <cfqueryparam cfsqltype="Integer" value="#arguments.fontFamilySizeId#">
			RETURNING font_family_size_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>
</cfcomponent>
