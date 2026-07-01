<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="frameId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT frame_id::varchar, *
			FROM
				frames
			WHERE
				frame_id = <cfqueryparam cfsqltype="varchar" value="#arguments.frameId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Recupera in batch più record dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query">
		<cfargument name="ids" type="Array" required="true">

		<cfif ArrayLen( arguments.ids ) EQ 0>
			<cfreturn QueryNew( "frame_id" )>
		</cfif>

		<cfset var idsList = ArrayToList( arguments.ids )>

		<cfquery name="local.q" datasource="apirone">
			SELECT frame_id::varchar, *
			FROM frames
			WHERE frame_id = ANY(
				<cfqueryparam value="#idsList#" list="false" cfsqltype="varchar">::uuid[]
			)
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
		<cfargument name="orientationId" type="String">
		<cfargument name="cellOrientationId" type="String">
		<cfargument name="statusId" type="String">

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
					AND frames.orientation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.orientationId#">
				</cfif>

				<cfif !IsNull( arguments.cellOrientationId )>
					AND frames.cell_orientation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.cellOrientationId#">
				</cfif>

				<cfif !IsNull( arguments.str )>
					AND
					(
						frames.code ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
						OR frames.frame ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
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
		<cfargument name="frame" type="com.apirone.core.model.bean.Frame" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO frames (
				code,
				frame,
				status_id,
				orientation_id,
				cell_orientation_id
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.frame.getCode()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.frame.getName()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.frame.getStatus().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.frame.getOrientation().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.frame.getCellOrientation().getId()#">
			) RETURNING frame_id
		</cfquery>

		<cfreturn local.q.frame_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="frame" type="com.apirone.core.model.bean.Frame" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				frames
			SET
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.frame.getStatus().getId()#">,
				frame = <cfqueryparam cfsqltype="Varchar" value="#arguments.frame.getName()#">,
				code = <cfqueryparam cfsqltype="Varchar" value="#arguments.frame.getCode()#">,
				orientation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.frame.getOrientation().getId()#">,
				cell_orientation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.frame.getCellOrientation().getId()#">
			WHERE
				frame_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.frame.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.frame.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="frameId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				frames
			WHERE
				frame_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.frameId#">::uuid
			RETURNING frame_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

</cfcomponent>
