<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		
		<cfargument name="quotationItemFruitPositionId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				quotation_item_fruits
			WHERE
				quotation_item_fruit_position_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemFruitPositionId#">
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationItemFruitId" type="String" required="false">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_item_fruit_position_id,
				COUNT(quotation_item_fruit_position_id) OVER() AS total
			FROM
				quotation_item_fruit_positions
			WHERE 1=1

				AND quotation_item_fruit_positions.quotation_item_fruit_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationItemFruitId#">::uuid

			ORDER BY
				#super.sanitizeSQL( arguments.orderBy )#
			<cfif arguments.limit GT 0>
				LIMIT
					<cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET
					<cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="Numeric">
		<cfargument name="quotationItemFruitId" type="String" required="true">
		<cfargument name="position" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_item_fruit_positions (
				quotation_item_fruit_id,
				position
			) VALUES (
				<cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemFruitId#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.position#">
			)
			RETURNING quotation_item_fruit_position_id
		</cfquery>
		
		<cfreturn local.q.quotation_item_fruit_position_id>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="quotationItemFruitPositionId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM
				quotation_item_fruit_positions
			WHERE
				quotation_item_fruit_position_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemFruitPositionId#">
		</cfquery>
		<cfreturn true>
	</cffunction>

	<cffunction name="deleteByQuotationItemFruitId" returntype="Boolean">
		<cfargument name="quotationItemFruitId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM
				quotation_item_fruit_positions
			WHERE
				quotation_item_fruit_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemFruitId#">
		</cfquery>
		<cfreturn true>
	</cffunction>
</cfcomponent>
