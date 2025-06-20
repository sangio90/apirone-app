<cfoutput>

    <cfquery name="rows" datasource="apirone">
        SELECT product_item_id, raw_value_id
        FROM product_items
        ORDER BY 1
    </cfquery>

    <cfloop query="rows">

        <cfquery name="value" datasource="apirone">
            SELECT *
            FROM attributes_raw_values
            WHERE raw_value_id = <cfqueryparam cfsqltype="Integer" value="#raw_value_id#">
            LIMIT 1
        </cfquery>

        <cfif value.recordCount>

            Aggiorno prodotto item: #product_item_id# con valore: #value.raw_value_id#<br>
            
            <cfquery name="updateItem" datasource="apirone">
                UPDATE product_items
                SET attribute_raw_value_id = <cfqueryparam cfsqltype="Integer" value="#value.attribute_raw_value_id#">
                WHERE product_item_id = <cfqueryparam cfsqltype="Integer" value="#product_item_id#">
            </cfquery>

        </cfif>

    </cfloop>

</cfoutput>