component extends="com.apirone.core.controller.AbsController" {

    function addItem( event, rc, prc ){

        var result = super.getResult();


        ```
        <cfquery datasource="apirone">
            DELETE FROM configurations
            WHERE 
                finish_id = '#rc.finishId#'
                    AND size_id = '#rc.sizeId#'
                    AND line_id = '#rc.lineId#'
                    AND attribute_id = '#rc.attributeId#'
        </cfquery>

        <cfset attr = super.fire( "attribute.get", [ rc.attributeId ] )>

        <cfloop array="#attr.getValues()#" item="item">

            <cfquery datasource="apirone">
                INSERT INTO configurations (
                    finish_id,
                    size_id,
                    attribute_value_id,
                    line_id,
                    attribute_id
                )
                VALUES (
                    '#rc.finishId#',
                    '#rc.sizeId#',
                    '#item.getId()#',
                    '#rc.lineId#',
                    '#rc.attributeId#'
                )
            </cfquery>
            
        </cfloop>

        ```

        var message = completeMessage( "configuration.saved" );

        result.setData( message );

        event.setValue("result", result);

    }

    function removeItems( event, rc, prc ){

        var result = super.getResult();


        ```
        <cfquery datasource="apirone">
            DELETE FROM configurations
            WHERE 
                finish_id = '#rc.finishId#'
                    AND size_id = '#rc.sizeId#'
                    AND line_id = '#rc.lineId#'
                    AND attribute_id = '#rc.attributeId#'
        </cfquery>

        <cfset attr = super.fire( "attribute.get", [ rc.attributeId ] )>

        <cfloop array="#attr.getValues()#" item="item">

            <cfquery datasource="apirone">
                INSERT INTO configurations (
                    finish_id,
                    size_id,
                    attribute_value_id,
                    line_id,
                    attribute_id
                )
                VALUES (
                    '#rc.finishId#',
                    '#rc.sizeId#',
                    '#item.getId()#',
                    '#rc.lineId#',
                    '#rc.attributeId#'
                )
            </cfquery>
            
        </cfloop>

        ```

        var message = completeMessage( "configuration.saved" );

        result.setData( message );

        event.setValue("result", result);

    }


}
