component extends="com.apirone.core.controller.AbsController" {

    function listItems( event, rc, prc ){

        var data = [];
        var dm = getDataMapper();
        var result = super.getResult();

        


        ```        
        <cfquery datasource="apirone" name="local.q">
            SELECT *
            FROM combination_items
            WHERE
                combination_id IS NULL
            AND parent_id IS NULL
        </cfquery>

        ```        

        var level = 0;
        var list = [];

        for( var record in local.q ) {

            var value = super.fire( "attributeValue.get", [ record.attribute_value_id ] );
            var valueObj = dm.convert( value, "AttributeValue", true );

            var row = {
                "attributeValue" = valueObj,
                "status" = super.fire( "status.get", [ record.status_id ] ),
                "level" = RepeatString( "&nbsp;&nbsp;&nbsp;",level ) 
            }

            list.add( row );
          

            var rows = recConfiguration( record, 0, rc );

            dump(rows.len());
            //abort;

            //list.merge( rows );

            for( var item in rows ) {
                list.add( item )
            }

        }

        result.setTotal( list.len() );
        result.setCount( list.len() );
        result.setData( list );

        event.setValue("result", result);

    }

    function recConfiguration( record, level, rc ){

        var dm = getDataMapper();


        ``` 
        <cfquery datasource="apirone" name="local.q">
            SELECT *
            FROM configurations 
            WHERE
                finish_id = '#arguments.rc.finishId#'
                AND size_id = '#arguments.rc.sizeId#'
                AND line_id = '#arguments.rc.lineId#'
            AND parent_id = #record.attribute_value_id#
        </cfquery>
        ``` 

        var list = []
        arguments.level = level+1;

        for( var record in local.q ) {

            var value = super.fire( "attributeValue.get", [ record.attribute_value_id ] );
            var valueObj = dm.convert( value, "AttributeValue", true );
    
            var row = {
                "attributeValue" = valueObj,
                "status" = super.fire( "status.get", [ record.status_id ] ),
                "level" = RepeatString( "&nbsp;&nbsp;&nbsp;", level ) 
            }

            list.add( row );
                
            var rows = recConfiguration( record, arguments.level, arguments.rc )

            for( var item in rows ) {
                list.add( item )
            }
    
        }

        return list;

    }        

    function listImages( event, rc, prc ){

        // union between those already inserted and the one to be inserted

        var comb = super.fire( "file.list", { rc.combinationId = rc.combinationId } );

        var lineId = comb.getLine().getId()

        var finishes = super.fire( "finish.list", { lineId: lineId, sizeId: rc.sizeId  } )>

        event.setValue("result", finishes);

    }

    function upload( event, rc, prc ){

        var tmpDir = getTempDir();
        var entity = super.bean("Entity");

		cffile( filefield=rc.files[1], nameconflict="MAKEUNIQUE", destination=tmpDir, action="UPLOAD" );

        entity.setType( "shipment" );
        entity.setValue( rc.shipmentId );
        
        store( filePath = "#tmpDir#/#cffile.ServerFile#", user = prc.user, entity = entity, typeId = rc.documentTypeId );

        var result = super.getResult();
        
        result.setData( { "message" = "File caricato" } );

        event.setValue( "result", result );
        
    }    

    function addItem( event, rc, prc ){

        var result = super.getResult();
        var attribute = super.fire( "attribute.get", [ rc.attributeId ] );

        ```
        <cfquery datasource="apirone">
            DELETE FROM combination_items
            WHERE 
                combination_id = '#rc.id#'
                AND attribute_value_id IN 
                    ( 
                        SELECT attribute_value_id 
                        FROM attribute_values 
                        WHERE attribute_id = '#rc.attributeId#'
                    )
        </cfquery>

        <cfloop array="#attribute.getValues()#" item="item">

            <cfquery datasource="apirone">
                INSERT INTO combination_items (
                    combination_id,
                    attribute_value_id
                )
                VALUES (
                    '#rc.id#',
                    '#item.getId()#'
                )
            </cfquery>
            
        </cfloop>

        ```

        var message = completeMessage( "configuration.saved" );

        result.setData( message );

        event.setValue( "result", result );

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

    private function store( filePath, user, entity, typeId ){

        var fileId = getAccessManager()
                .exec( 
                    arguments.user,
                    "file.store", 
                    { 
                        filePath       = arguments.filePath,
                        accountId      = user.getAccount().getId(),
                        scope          = "shipments",
                        documentTypeId = arguments.typeId,
                        entity         = arguments.entity
                     } 
                );

        return fileId;
       
    }    

}
