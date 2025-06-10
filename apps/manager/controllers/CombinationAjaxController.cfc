component extends="com.apirone.core.controller.AbsController" {

    function listItems( event, rc, prc ){

        var data = [];
        var result = super.getResult();

        var  items = super.fire("ProductItem.getFlatTree", { combinationId = rc.id } );

        //dump(items.len());
        //abort;

        for( var item in items ) {

            var row = super.getDataMapper().convert( item, "ProductItem", true );

            row["level"] = RepeatString( "&nbsp;&nbsp;&nbsp;&nbsp;", item.getLevel() );

            data.add( row );

        }

        result.setTotal( data.len() );
        result.setCount( data.len() );
        result.setData( data );

        event.setValue("result", result);

    }

    function addItem( event, rc, prc ){

        var result = super.getResult();
        var attribute = super.fire( "attribute.get", [ rc.attributeId ] );

        param rc.id = '_';          //Current combination
        param rc.parentId = 0;      //Parent item, if exists
        param rc.attributeId = 0;   //To add values ​​to this attribute

        ```
        <cftransaction>
        
            <cfquery datasource="apirone">
                DELETE FROM product_items
                WHERE 
                    combination_id = <cfqueryparam cfsqltype="Varchar" value="#rc.id#">::uuid
                    AND attribute_raw_value_id IN 
                        ( 
                            SELECT attribute_raw_value_id 
                            FROM attributes_raw_values 
                            WHERE attribute_id = <cfqueryparam cfsqltype="Varchar" value="#rc.attributeId#">::uuid
                        )
            </cfquery>

            <cfloop array="#attribute.getValues()#" item="item">

                <cfquery datasource="apirone">
                    INSERT INTO product_items (
                        combination_id,
                        attribute_raw_value_id,
                        orderby,
                        parent_id
                    )
                    VALUES (
                        '#rc.id#',
                        '#item.getId()#',
                        #item.getOrderBy()#,
                        #( Val(rc.parentId) ? rc.parentId : 'NULL' )#
                    )
                </cfquery>
                
            </cfloop>

        </cftransaction>

        ```

        var message = completeMessage( "combination.itemsAdded" );

        result.setData( { "message" = message } );

        event.setValue( "result", result );

    }
    
    function removeItems( event, rc, prc ){

        var result = super.getResult();

        param rc.items = "_";


        ```
        <!--- TODO: better than this --->
        <cfquery datasource="apirone">
            DELETE FROM product_items
            WHERE product_item_id IN ( #rc.items# )
        </cfquery>

        ```

        var message = completeMessage( "combination.itemsDeleted" );

        result.setData( { "message" = message } );

        event.setValue("result", result);

    }

}
