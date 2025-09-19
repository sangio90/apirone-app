<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="lineId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT frame_id::varchar, *
			FROM
				frames
			WHERE
				frame_id = <cfqueryparam cfsqltype="varchar" value="#arguments.lineId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="readByCode" output="false">
		<cfargument name="code" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				frame_id::varchar,
				*
			FROM
				frames
			WHERE
				code = <cfqueryparam cfsqltype="varchar" value="#arguments.code#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String">
		<cfargument name="statusId" type="Numeric">
		<cfargument name="orientationId" type="Varchar">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="code">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				DISTINCT frame_id::varchar,
				COUNT(frame_id) OVER() AS total
			FROM
				frames
			WHERE 1=1

				<cfif !IsNull( arguments.statusId )>
					AND frames.status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.statusId#">
				</cfif>

				<cfif !IsNull( arguments.orientationId )>
					AND frames.orientation_id = <cfqueryparam cfsqltype="Integer" value="#arguments.catalogBundleCategoryId#">
				</cfif>

				<cfif !IsNull( arguments.str )>
					AND
					(
						frames.code ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
						OR frames.line ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
					)
				</cfif>

			ORDER BY
				frame_id

			<cfif arguments.limit GT 0>
				LIMIT
					<cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET
					<cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String" output="false">
		<cfargument name="line" type="com.apirone.core.model.bean.Line" required="true">

		<cfset var categories = super.getCategoriesAsArray( line.getCategories() )>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO frames (
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
			) RETURNING frame_id
		</cfquery>

		<cfreturn local.q.frame_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="line" type="com.apirone.core.model.bean.Line" required="true">

		<cfset var categories = super.getCategoriesAsArray( line.getCategories() )>

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				frames
			SET
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.line.getStatus().getId()#">,
				line = <cfqueryparam cfsqltype="Varchar" value="#arguments.line.getName()#">,
				code = <cfqueryparam cfsqltype="Varchar" value="#arguments.line.getCode()#">,
				orderby = 20,
				categories = '#SerializeJSON( categories )#'
			WHERE
				frame_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.line.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.line.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="lineId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				frames
			WHERE
				frame_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
			RETURNING frame_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

	<cffunction name="findCells" returntype="Query">
		<cfargument name="frameId" type="string" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				frame_cell_id,
				frame_id,
				row,
				col,
				value
			FROM
				frame_cells
			WHERE
				frame_id = <cfqueryparam cfsqltype="varchar" value="#frameId#">::uuid
			ORDER BY
				row, col
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="deleteCells" returntype="Query">
		<cfargument name="frameId" type="string" required="true">

		<cfquery name="local.qDeleteCells" datasource="apirone">
			DELETE FROM frame_cells
			WHERE frame_id = <cfqueryparam cfsqltype="varchar" value="#arguments.frameId#">::uuid
		</cfquery>

		<cfreturn true>
	</cffunction>

	<cffunction name="saveCells" returntype="Boolean">
		<cfargument name="cells" type="com.apirone.core.model.bean.FrameCell[]" required="true">

		<cfloop array="#arguments.cells#" index="cell">
			<cfquery name="local.qInsertCell" datasource="apirone">
				INSERT INTO frame_cells (
					frame_id,
					row,
					col,
					value
				) VALUES (
					<cfqueryparam cfsqltype="varchar" value="#arguments.cell.getFrameId()#">::uuid,
					<cfqueryparam cfsqltype="integer" value="#arguments.cell.getRow()#">,
					<cfqueryparam cfsqltype="integer" value="#arguments.cell.getCol()#">,
					<cfqueryparam cfsqltype="varchar" value="#arguments.cell.getValue()#">
				)
			</cfquery>
		</cfloop>

		<cfreturn true>
	</cffunction>
</cfcomponent>

