<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="zoneId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_zone_id::varchar,
				quotation_id::varchar,
				origin_id::varchar,
				*
			FROM quotation_zones
			WHERE quotation_zone_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.zoneId#">::uuid
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<!---
		Recupera in batch più record dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query">
		<cfargument name="ids" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.ids )>

		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_zone_id::varchar,
				quotation_id::varchar,
				origin_id::varchar,
				*
			FROM quotation_zones
			WHERE quotation_zone_id = ANY( ARRAY[<cfqueryparam value="#idsList#" list="true" cfsqltype="varchar">]::uuid[] )
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationId" type="String" required="false">
		<cfargument name="originId" type="String" required="false">
		<cfargument name="name" type="String" required="false">
		<cfargument name="orderBy" type="String" required="true" default="quotation_zone_id">
		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_zone,
				quotation_zone_id::varchar,
				quotation_id::varchar,
				origin_id::varchar,
				COUNT(quotation_zone_id) OVER() AS total
			FROM
				quotation_zones
			WHERE 1=1
				<cfif !IsNull( arguments.name )>
					AND quotation_zone = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.name#">
				</cfif>
				<cfif !IsNull( arguments.quotationId )>
					AND quotation_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationId#">::uuid
				</cfif>
				<cfif !IsNull( arguments.originId )>
					AND origin_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.originId#">::uuid
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
			INSERT INTO quotation_zones (
				quotation_id,
				quotation_zone,
				quantity,
				origin_id
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.zone.getQuotation().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.zone.getName()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.zone.getQuantity()#">,
				<cfif !IsNull( arguments.zone.getOrigin() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.zone.getOrigin().getId()#">::uuid
				<cfelse>
					NULL
				</cfif>
			)
			RETURNING quotation_zone_id
		</cfquery>
		<cfreturn local.q.quotation_zone_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="zone" type="com.apirone.core.model.bean.QuotationZone" required="true">
		<cfquery name="local.q" datasource="apirone">
			UPDATE quotation_zones
			SET
				quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.zone.getQuotation().getId()#">::uuid,
				quotation_zone = <cfqueryparam cfsqltype="Varchar" value="#arguments.zone.getName()#">,
				quantity = <cfqueryparam cfsqltype="Integer" value="#arguments.zone.getQuantity()#">,
				<cfif !IsNull( arguments.zone.getOrigin() )>
					origin_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.zone.getOrigin().getId()#">::uuid
				<cfelse>
					origin_id = null
				</cfif>
			WHERE
				quotation_zone_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.zone.getId()#">::uuid
		</cfquery>
		<cfreturn arguments.zone.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="zoneId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM
				quotation_zones
			WHERE
				quotation_zone_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.zoneId#">::uuid
		</cfquery>
		<cfreturn true>
	</cffunction>
</cfcomponent>
