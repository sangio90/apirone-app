<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read" returntype="Query">
		<cfargument name="draftId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_item_draft_id::varchar,
				quotation_id::varchar,
				quotation_zone_id::varchar,
				item_type,
				coordinate_x,
				coordinate_y,
				angle,
				created_at
			FROM quotation_item_drafts
			WHERE quotation_item_draft_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.draftId#">::uuid
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="findByZone" returntype="Query">
		<cfargument name="quotationZoneId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_item_draft_id::varchar,
				quotation_id::varchar,
				quotation_zone_id::varchar,
				item_type,
				coordinate_x,
				coordinate_y,
				angle,
				created_at
			FROM quotation_item_drafts
			WHERE quotation_zone_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.quotationZoneId#">::uuid
			ORDER BY created_at ASC
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="countByQuotation" returntype="Numeric">
		<cfargument name="quotationId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			SELECT COUNT(*) AS total
			FROM quotation_item_drafts
			WHERE quotation_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.quotationId#">::uuid
		</cfquery>
		<cfreturn Val( local.q.total )>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="draft" type="com.apirone.core.model.bean.QuotationItemDraft" required="true">
		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_item_drafts (
				quotation_id,
				quotation_zone_id,
				item_type,
				coordinate_x,
				coordinate_y,
				angle
			) VALUES (
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.draft.getQuotationId()#">::uuid,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.draft.getQuotationZoneId()#">::uuid,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.draft.getItemType()#">,
				<cfqueryparam cfsqltype="CF_SQL_NUMERIC" value="#arguments.draft.getCoordinateX()#">,
				<cfqueryparam cfsqltype="CF_SQL_NUMERIC" value="#arguments.draft.getCoordinateY()#">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Val( arguments.draft.getAngle() )#">
			)
			RETURNING quotation_item_draft_id::varchar
		</cfquery>
		<cfreturn local.q.quotation_item_draft_id>
	</cffunction>

	<cffunction name="update" returntype="void">
		<cfargument name="draft" type="com.apirone.core.model.bean.QuotationItemDraft" required="true">
		<cfquery datasource="apirone">
			UPDATE quotation_item_drafts
			SET
				coordinate_x = <cfqueryparam cfsqltype="CF_SQL_NUMERIC" value="#arguments.draft.getCoordinateX()#">,
				coordinate_y = <cfqueryparam cfsqltype="CF_SQL_NUMERIC" value="#arguments.draft.getCoordinateY()#">,
				angle        = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Val( arguments.draft.getAngle() )#">
			WHERE quotation_item_draft_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.draft.getId()#">::uuid
		</cfquery>
	</cffunction>

	<cffunction name="delete" returntype="void">
		<cfargument name="draftId" type="String" required="true">
		<cfquery datasource="apirone">
			DELETE FROM quotation_item_drafts
			WHERE quotation_item_draft_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.draftId#">::uuid
		</cfquery>
	</cffunction>

</cfcomponent>
