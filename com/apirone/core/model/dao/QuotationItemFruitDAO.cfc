<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="quotationItemFruitId" type="Numeric" required="true">
		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				quotation_item_fruits
			WHERE
				quotation_item_fruit_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemFruitId#">
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationItemId" type="String" required="false">
		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">
		<cfargument name="orderby" type="String" required="true" default="created_at DESC">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_item_fruit_id,
				COUNT(quotation_item_fruit_id) OVER() AS total
			FROM
				quotation_item_fruits
			WHERE 1=1

				<cfif !IsNull( arguments.quotationItemId )>
					AND quotation_item_fruits.quotation_item_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationItemId#">::uuid
				</cfif>

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
		<cfargument name="quotationItemFruit" type="com.apirone.core.model.bean.QuotationItemFruit" required="true">
		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_item_fruits (
				quotation_item_id,
				position,
				fruit_id
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemFruit.getQuotationItemId()#">::uuid,
				<cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemFruit.getPosition()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemFruit.getFruit().getId()#">::uuid
			)
			RETURNING quotation_item_fruit_id
		</cfquery>
		<cfreturn local.q.quotation_item_fruit_id>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="quotationItemFruit" type="com.apirone.core.model.bean.QuotationItemFruit" required="true">
		<cfquery name="local.q" datasource="apirone">
			UPDATE quotation_item_fruits
			SET
				position = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemFruit.getPosition()#">,
				fruit_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemFruit.getFruit().getId()#">::uuid
			WHERE
				quotation_item_fruit_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemFruit.getId()#">
		</cfquery>
		<cfreturn arguments.quotationItemFruit.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="quotationItemFruitId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM
				quotation_item_fruits
			WHERE
				quotation_item_fruit_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemFruitId#">
		</cfquery>
		<cfreturn true>
	</cffunction>
</cfcomponent>
