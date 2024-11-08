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

    /*
    function combinations( event, rc, prc ){

        var result = [];

        var combinationsList = super.fire( "combination.list", { lineId = rc.id } );

        for( var combination in combinationsList ) {
            result.add( "#combination.getSize().getId()#__#combination.getFinish().getId()#" );
        }

        event.setValue("result", result);
        
    }
    */

    function createCombination( event, rc, prc ){

        var json = DESerializeJSON( GetHTTPRequestData().content );

        var line = super.bean("Line");
        var size = super.bean("Size");
        var finish = super.bean("Finish");
        var combination = super.bean("Combination");

        combination.setLine( line.setId( rc.id ) );
        combination.setFinish( finish.setId( json.finishId ) );
        combination.setSize( size.setId( json.sizeId ) );
        
        var newId = super.fire( "combination.create", [ combination ] );

        var message = super.completeMessage( "combination.created" );

        var obj = super.fire( "combination.get", [ newId ] );

        event.setValue( "result", { 
            "message": message, 
            "payload" = { "combinationId" = newId, "finishId" = obj.getFinish().getId(), "sizeId" = obj.getSize().getId() }
        } );
        
    }

    function deleteCombination( event, rc, prc ){

        var json = DESerializeJSON( GetHTTPRequestData().content );

        super.fire( "combination.deleteByParams", { sizeId = json.sizeId, lineId = rc.id, finishId = json.finishId } );

        var message = super.completeMessage( "combination.deleted" );

        event.setValue( "result", { 
            "message": message, 
            //"payload" = { "combinationId" = newId, "finishId" = obj.getFinish().getId(), "sizeId" = obj.getSize().getId() }
        } );
        
    }

}
