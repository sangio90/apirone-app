<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="positionId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_item_position_id::varchar,
				quotation_item_id::varchar,
				*
			FROM quotation_item_positions
			WHERE quotation_item_position_id = <cfqueryparam cfsqltype="Integer" value="#arguments.positionId#">
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationItemId" type="String" required="false">
		<cfargument name="sequence" type="Numeric" required="false">
		<cfargument name="orderBy" type="String" required="true" default="quotation_item_position_id">
		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_item_position_id::varchar,
				quotation_item_id::varchar,
				COUNT(quotation_item_position_id) OVER() AS total
			FROM
				quotation_item_positions
			WHERE 1=1
				<cfif !IsNull( arguments.quotationItemId )>
					AND quotation_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemId#">::uuid
				</cfif>
				<cfif !IsNull( arguments.sequence )>
					AND "sequence" = <cfqueryparam cfsqltype="Integer" value="#arguments.sequence#">
				</cfif>

			ORDER BY #super.sanitizeSQL( arguments.orderBy )#

			<cfif arguments.limit GT 0>
				LIMIT <cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET <cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="getMaxSequenceByQuotationItemId" returntype="numeric">
		<cfargument name="quotationItemId" type="string" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				MAX("sequence") AS max_sequence
			FROM
				quotation_item_positions
			WHERE quotation_item_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationItemId#">::uuid
		</cfquery>
		
		<cfreturn isNumeric(local.q.max_sequence) ? local.q.max_sequence : 0>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="position" type="com.apirone.core.model.bean.QuotationItemPosition" required="true">
		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_item_positions (
				quotation_item_id,
				"sequence"
				<cfif !IsNull( arguments.coordinate_x )>
					,coordinate_x
				</cfif>
				<cfif !IsNull( arguments.coordinate_y )>
					,coordinate_y
				</cfif>
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.position.getQuotationItemId()#">::uuid,
				<cfqueryparam cfsqltype="Integer" value="#arguments.position.getSequence()#">
				<cfif !IsNull( arguments.coordinate_x )>
					,<cfqueryparam cfsqltype="Numeric" value="#arguments.position.getCoordinateX()#">
				</cfif>
				<cfif !IsNull( arguments.coordinate_y )>
					,<cfqueryparam cfsqltype="Numeric" value="#arguments.position.getCoordinateY()#">
				</cfif>
			)
			RETURNING quotation_item_position_id
		</cfquery>
		<cfreturn local.q.quotation_item_position_id>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="position" type="com.apirone.core.model.bean.QuotationItemPosition" required="true">
		<cfquery name="local.q" datasource="apirone">
			UPDATE quotation_item_positions
			SET
				quotation_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.position.getQuotationItemId()#">::uuid,
				"sequence" = <cfqueryparam cfsqltype="Integer" value="#arguments.position.getSequence()#">,
				coordinate_x = <cfqueryparam cfsqltype="Numeric" value="#arguments.position.getCoordinateX()#">,
				coordinate_y = <cfqueryparam cfsqltype="Numeric" value="#arguments.position.getCoordinateY()#">
			WHERE
				quotation_item_position_id = <cfqueryparam cfsqltype="Integer" value="#arguments.position.getId()#">
		</cfquery>
		<cfreturn arguments.position.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="positionId" type="Numeric" required="true">
		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM
				quotation_item_positions
			WHERE
				quotation_item_position_id = <cfqueryparam cfsqltype="Integer" value="#arguments.positionId#">
		</cfquery>
		<cfreturn true>
	</cffunction>
</cfcomponent>
