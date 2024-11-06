component extends="com.apirone.core.controller.AbsController" {

    function configuration( event, rc, prc ){

        var data = [];
        var dm = getDataMapper();
        var result = super.getResult();
        

        ```        
        <cfquery datasource="apirone" name="local.q">
            SELECT *
            FROM configurations 
            WHERE
                finish_id = '#rc.finishId#'
                AND size_id = '#rc.sizeId#'
                AND line_id = '#rc.lineId#'
        </cfquery>

        ```        

        for( var record in local.q ) {

            var value = super.fire( "attributeValue.get", [ record.attribute_value_id ] );

            var valueObj = dm.convert( value, "AttributeValue", true );
                
            var row = {
                "attributeValue" = valueObj,
                "status" = super.fire( "status.get", [ record.status_id ] )
            }

            data.add( row );

        }

        result.setTotal( data.len() );
        result.setCount( data.len() );
        result.setData( data );

        event.setValue("result", result);

    }


    function addValue( event, rc, prc ){

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

        <cfset attr = super.fire("attribute.get", [ rc.attributeId ] )>

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

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = getDataMapper();
        
        var rows = super.fire( "line.list" );

        for ( var row in rows ) {
            var obj = dm.convert( row, "Line", true );
            data.add( obj );
        }

        result.setTotal( data.len() );
        result.setCount( data.len() );
        result.setData( data );

        event.setValue("result", result);

    }

    function attributes( event, rc, prc ){

        param rc.str="";
        var result = super.getResult();

        var params = {}

        params.str = Len( rc.str ) ? rc.str : NullValue();

        var list = fire( "attributes.search", params );

        dump(list);
        abort;

        result = list;

        event.setValue("result", result);
        
    }

}
