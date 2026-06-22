<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="frameCellId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT frame_id::varchar, *
			FROM
				frame_cells
			WHERE
				frame_cell_id = <cfqueryparam cfsqltype="Integer" value="#arguments.frameCellId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Recupera in batch più record dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query">
		<cfargument name="ids" type="Array" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				frame_cells
			WHERE
				frame_cell_id::varchar IN (<cfqueryparam value="#ArrayToList( arguments.ids )#" list="true" cfsqltype="varchar">)
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Recupera in batch i FrameCell per una lista di frameId.
		Utilizzato da FrameService.getMany() per evitare QueryExecute con list:true.
	--->
	<cffunction name="readByFrameIds" returntype="Query" access="public">
		<cfargument name="frameIds" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.frameIds )>

		<cfquery name="local.q" datasource="apirone">
			SELECT frame_id::varchar, *
			FROM frame_cells
			WHERE frame_id::varchar IN (
				<cfqueryparam value="#idsList#" list="true" cfsqltype="varchar">
			)
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="frameId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="code">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				DISTINCT frame_cell_id::varchar,
				COUNT(frame_cell_id) OVER() AS total
			FROM
				frame_cells
			WHERE 1=1

				<cfif !IsNull( arguments.frameId )>
					AND frame_cells.frame_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.frameId#">::uuid
				</cfif>

			ORDER BY
				frame_cell_id

			<cfif arguments.limit GT 0>
				LIMIT
					<cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET
					<cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="Boolean">
		<cfargument name="cell" type="com.apirone.core.model.bean.FrameCell" required="true">

		<cfquery name="local.qInsertCell" datasource="apirone">
			INSERT INTO frame_cells (
				frame_id,
				row,
				col,
				width,
				height,
				orientation_id,
				type_id
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.cell.getFrameId()#">::uuid,
				<cfqueryparam cfsqltype="Integer" value="#arguments.cell.getRow()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.cell.getCol()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.cell.getWidth()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.cell.getHeight()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.cell.getOrientation().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.cell.getType().getId()#">
			)
		</cfquery>

		<cfreturn true>
	</cffunction>

	<cffunction name="deleteByFrameId" returntype="Query">
		<cfargument name="frameId" type="string" required="true">

		<cfquery name="local.qDeleteCells" datasource="apirone">
			DELETE FROM frame_cells
			WHERE frame_id = <cfqueryparam cfsqltype="varchar" value="#arguments.frameId#">::uuid
		</cfquery>

		<cfreturn true>
	</cffunction>

</cfcomponent>
