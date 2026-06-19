<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="frameBlockId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT frame_id::varchar, *
			FROM
				frame_blocks
			WHERE
				frame_block_id = <cfqueryparam cfsqltype="Integer" value="#arguments.frameBlockId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="frameId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="order">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				frame_block_id::varchar,
				COUNT(frame_block_id) OVER() AS total
			FROM
				frame_blocks
			WHERE 1=1

				<cfif !IsNull( arguments.frameId )>
					AND frame_blocks.frame_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.frameId#">::uuid
				</cfif>

			ORDER BY
				"order"

			<cfif arguments.limit GT 0>
				LIMIT
					<cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET
					<cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="block" type="com.apirone.core.model.bean.FrameBlock" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO frame_blocks (
				frame_id,
				"order",
				slot_count,
				margin_top_mm,
				margin_left_mm,
				orientation_mode,
				rotatable
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.block.getFrameId()#">::uuid,
				<cfqueryparam cfsqltype="Integer" value="#arguments.block.getOrder()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.block.getSlotCount()#">,
				<cfqueryparam cfsqltype="Decimal" scale="2" value="#arguments.block.getMarginTopMm()#">,
				<cfqueryparam cfsqltype="Decimal" scale="2" value="#arguments.block.getMarginLeftMm()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.block.getOrientationMode()#">,
				<cfqueryparam cfsqltype="CF_SQL_BIT" value="#(arguments.block.getRotatable() ? 1 : 0)#">
			) RETURNING frame_block_id
		</cfquery>

		<cfreturn local.q.frame_block_id.toString()>
	</cffunction>

	<cffunction name="deleteByFrameId" returntype="Boolean">
		<cfargument name="frameId" type="string" required="true">

		<cfquery name="local.qDeleteBlocks" datasource="apirone">
			DELETE FROM frame_blocks
			WHERE frame_id = <cfqueryparam cfsqltype="varchar" value="#arguments.frameId#">::uuid
		</cfquery>

		<cfreturn true>
	</cffunction>

</cfcomponent>
