<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="lineId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT line_id::varchar, *
			FROM
				lines
			WHERE
				line_id = <cfqueryparam cfsqltype="varchar" value="#arguments.lineId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="readByCode" output="false">
		<cfargument name="code" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				line_id::varchar,
				*
			FROM
				lines
			WHERE
				code = <cfqueryparam cfsqltype="varchar" value="#arguments.code#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String">
		<cfargument name="categoryId" type="Numeric">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="code">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				line_id::varchar,
				COUNT(line_id) OVER() AS total
			FROM
				lines
			WHERE 1=1

				<cfif !IsNull( arguments.categoryId )>
					AND categories @> ANY ('{[#sanitizeSQL( arguments.categoryId )#]}')
				</cfif>

				<cfif !IsNull( arguments.statusId )>
					AND lines.status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.statusId#">
				</cfif>

				<cfif !IsNull( arguments.str )>
					AND
					(
						lines.code ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
						OR lines.line ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
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

		<cfdump var="#local.q#">
		<cfdump var="#arguments#">

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String" output="false">
		<cfargument name="line" type="com.apirone.core.model.bean.Line" required="true">

		<cfset var categories = super.getCategoriesAsArray( line.getCategories() )>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO lines (
				code,
				line,
				status_id,
				<!--- product_category_id, --->
				<!--- thickness_id, --->
				orderby,
				categories
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.line.getCode()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.line.getName()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.line.getStatus().getId()#">,
				<!--- <cfqueryparam cfsqltype="Integer" value="#arguments.line.getCategory().getId()#"> --->
				<!--- <cfqueryparam cfsqltype="Integer" value="#arguments.line?.getTickness()?.getId()#"> --->
				10,
				'#SerializeJSON( categories )#'
			) RETURNING line_id
		</cfquery>

		<cfreturn local.q.line_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="line" type="com.apirone.core.model.bean.Line" required="true">

		<cfset var categories = super.getCategoriesAsArray( line.getCategories() )>

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				lines
			SET
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.line.getStatus().getId()#">,
				line = <cfqueryparam cfsqltype="Varchar" value="#arguments.line.getName()#">,
				code = <cfqueryparam cfsqltype="Varchar" value="#arguments.line.getCode()#">,
				<!---
			thickness_id =
			<cfqueryparam cfsqltype="Varchar" value="#arguments.line?.getThickness()?.getId()#">,
		--->
				orderby = 20,
				categories = '#SerializeJSON( categories )#'
			WHERE
				line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.line.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.line.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="lineId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				lines
			WHERE
				line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
			RETURNING line_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>
</cfcomponent>

