<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
    <cffunction name="read" returntype="Query">
        <cfargument name="zoneId" type="String" required="true">

        <cfquery name="local.q" datasource="apirone">
            SELECT
                quotation_item_zone_id::varchar,
                quotation_item_id::varchar,
                parent_id::varchar,
                *
            FROM quotation_item_zones
            WHERE quotation_item_zone_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.zoneId#">::uuid
        </cfquery>
        <cfreturn local.q>
    </cffunction>

    <cffunction name="find" returntype="Query">
        <cfargument name="quotationItemId" type="String" required="false">
        <cfargument name="parentId" type="String" required="false">
        <cfargument name="orderBy" type="String" required="true" default="quotation_item_zone_id">
        <cfargument name="limit" type="Numeric" required="true" default="15">
        <cfargument name="offset" type="Numeric" required="true" default="0">

        <cfquery name="local.q" datasource="apirone" result="result">
            SELECT
                quotation_item_zone_id::varchar,
                quotation_item_id::varchar,
                parent_id::varchar,
                COUNT(quotation_item_zone_id) OVER() AS total
            FROM 
                quotation_item_zones
            WHERE 1=1
                <cfif !isNull(arguments.quotationItemId)>
                    AND quotation_item_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationItemId#">::uuid
                </cfif>
                <cfif !isNull(arguments.parentId)>
                    AND parent_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.parentId#">::uuid
                </cfif>
            ORDER BY #super.sanitizeSQL(arguments.orderBy)#

            <cfif arguments.limit GT 0>
                LIMIT <cfqueryparam value="#arguments.limit#" cfsqltype="integer">
                OFFSET <cfqueryparam value="#arguments.offset#" cfsqltype="integer">
            </cfif>
        </cfquery>

        <cfreturn local.q>
    </cffunction>

    <cffunction name="insert" returntype="String">
        <cfargument name="zone" type="com.apirone.core.model.bean.QuotationItemZone" required="true">
        <cfquery name="local.q" datasource="apirone">
            INSERT INTO quotation_item_zones (
                quotation_item_id,
                quotation_item_zone,
                parent_id
            ) VALUES (
                <cfqueryparam cfsqltype="Varchar" value="#arguments.zone.getQuotationItem().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.zone.getName()#">,
                <cfif !IsNull( arguments.zone.getParent() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.zone.getParent().getId()#">::uuid
				<cfelse>
					NULL
				</cfif>
            )
            RETURNING quotation_item_zone_id
        </cfquery>
        <cfreturn local.q.quotation_item_zone_id.toString()>
    </cffunction>

    <cffunction name="update" returntype="String">
        <cfargument name="zone" type="com.apirone.core.model.bean.QuotationItemZone" required="true">
        <cfquery name="local.q" datasource="apirone">
            UPDATE quotation_item_zones
            SET
                quotation_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.zone.getQuotationItem().getId()#">::uuid,
				quotation_item_zone = <cfqueryparam cfsqltype="Varchar" value="#arguments.zone.getName()#">
                <cfif !IsNull( arguments.zone.getParent() )>
					,parent_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.zone.getParent().getId()#">::uuid
				</cfif>
            WHERE 
                quotation_item_zone_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.zone.getId()#">::uuid
        </cfquery>
        <cfreturn arguments.zone.getId()>
    </cffunction>

    <cffunction name="delete" returntype="Boolean">
        <cfargument name="zoneId" type="String" required="true">
        <cfquery name="local.q" datasource="apirone">
            DELETE 
            FROM 
                quotation_item_zones
            WHERE 
                quotation_item_zone_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.zoneId#">::uuid
        </cfquery>
        <cfreturn true>
    </cffunction>

</cfcomponent>
