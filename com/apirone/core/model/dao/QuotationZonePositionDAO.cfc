<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="zonePositionId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				*
			FROM quotation_zone_positions
			WHERE quotation_zone_position_id = <cfqueryparam cfsqltype="Integer" value="#arguments.zonePositionId#">
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationZoneId" type="String" required="false">
		
		<cfargument name="orderBy" type="String" required="true" default="quotation_zone_position_id">
		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_zone_position_id::varchar,
				COUNT(quotation_zone_position_id) OVER() AS total
			FROM
				quotation_zone_positions 
			WHERE 1=1
				<cfif !IsNull( arguments.quotationZoneId )>
					AND quotation_zone_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationZoneId#">::uuid
				</cfif>
			ORDER BY
				#super.sanitizeSQL( arguments.orderBy )#

			<cfif arguments.limit GT 0>
				LIMIT <cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET <cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="zone" type="com.apirone.core.model.bean.QuotationZone" required="true">
		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_zone_positions (
				quotation_zone_id,
				code,
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.zone.getQuotationZoneId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.zone.getCode()#">
			)
			RETURNING quotation_zone_position_id
		</cfquery>
		<cfreturn local.q.quotation_zone_position_id>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="zoneId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM quotation_zone_positions
			WHERE
				quotation_zone_position_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.zonePositionId#">
		</cfquery>
		<cfreturn true>
	</cffunction>

</cfcomponent>
