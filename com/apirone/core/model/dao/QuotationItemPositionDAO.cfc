<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
    <cffunction name="read" returntype="Query">
        <cfargument name="positionId" type="String" required="true">

        <cfquery name="local.q" datasource="apirone">
            SELECT
                quotation_item_position_id::varchar,
                quotation_item_zone_id::varchar,
                *
            FROM quotation_item_positions
            WHERE quotation_item_position_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.positionId#">::uuid
        </cfquery>
        <cfreturn local.q>
    </cffunction>

    <cffunction name="find" returntype="Query">
        <cfargument name="zoneId" type="String" required="false">
        <cfargument name="orderBy" type="String" required="true" default="quotation_item_position_id">
        <cfargument name="limit" type="Numeric" required="true" default="15">
        <cfargument name="offset" type="Numeric" required="true" default="0">

        <cfquery name="local.q" datasource="apirone" result="result">
            SELECT
                quotation_item_position_id::varchar,
                quotation_item_zone_id::varchar,
                COUNT(quotation_item_position_id) OVER() AS total
            FROM 
                quotation_item_positions
            WHERE 1=1
                <cfif !isNull(arguments.zoneId)>
                    AND quotation_item_zone_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.zoneId#">::uuid
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
        <cfargument name="position" type="com.apirone.core.model.bean.QuotationItemPosition" required="true">
        <cfquery name="local.q" datasource="apirone">
            INSERT INTO quotation_item_positions (
                quotation_item_zone_id,
                position_coordinate_x,
                position_coordinate_y
            ) VALUES (
                <cfqueryparam cfsqltype="Varchar" value="#arguments.position.getQuotationItemZone().getId()#">::uuid,
                <cfqueryparam cfsqltype="Varchar" value="#arguments.position.getPositionCoordinateX()#">,
                <cfqueryparam cfsqltype="Varchar" value="#arguments.position.getPositionCoordinateY()#">
            )
            RETURNING quotation_item_position_id
        </cfquery>
        <cfreturn local.q.quotation_item_position_id.toString()>
    </cffunction>

    <cffunction name="update" returntype="String">
        <cfargument name="position" type="com.apirone.core.model.bean.QuotationItemPosition" required="true">
        <cfquery name="local.q" datasource="apirone">
            UPDATE quotation_item_positions
            SET
                quotation_item_zone_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.position.getQuotationItemZone().getId()#">::uuid,
                position_coordinate_x = <cfqueryparam cfsqltype="Varchar" value="#arguments.position.getPositionCoordinateX()#">,
                position_coordinate_y = <cfqueryparam cfsqltype="Varchar" value="#arguments.position.getPositionCoordinateY()#">
            WHERE 
                quotation_item_position_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.position.getId()#">::uuid
        </cfquery>
        <cfreturn arguments.position.getId()>
    </cffunction>

    <cffunction name="delete" returntype="Boolean">
        <cfargument name="positionId" type="String" required="true">
        <cfquery name="local.q" datasource="apirone">
            DELETE 
            FROM 
                quotation_item_positions
            WHERE 
                quotation_item_position_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.positionId#">::uuid
        </cfquery>
        <cfreturn true>
    </cffunction>

</cfcomponent>
