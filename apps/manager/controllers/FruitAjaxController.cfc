component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = getDataMapper();

        var params = super.paramsFromUrl();

        dump(params);

        var rows = super.fire( "fruit.search", params );

        for ( var row in rows.getData() ) {
            var obj = dm.convert( row, "Fruit", true );
            data.add( obj );
        }

        result.setTotal( rows.getTotal() );
        result.setCount( rows.getCount() );
        result.setData( data );

        event.setValue("result", result);

    }

    function get( event, rc, prc ){

        param rc.id = "___";
        var result = super.getResult();

        if ( !super.isUuid( rc.id ) ) {
            return event.setValue("result", "No UUID");
        }

        var bean = super.fire( "fruit.get", [ rc.id ] );

        var obj = super.getDataMapper().convert( bean, "Fruit", true );

        result.setData( obj );

        event.setValue("result", result);

    }

	function codeExists( event, rc, prc ){
		param rc.id   = "_";
		param rc.code = "";

		var result = super.fire( "fruit.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var result = super.getResult();

		var fruit      = super.bean( "Fruit" );
		var status     = super.bean( "Status" );
		var statusText = super.bean( "Status" );
		var text       = super.bean( "Text" );
		var lang       = super.bean( "Lang" );

		var json = deserializeJSON( getHTTPRequestData().content );

		fruit.setId( json.id );
		fruit.setCode( json.code );

		fruit.setStatus( status.setId( json.status.id ) );
        fruit.setPositionsCount( json.positionsCount )

        text.setLang( lang.setId( json.mainText.lang.id ) );
        text.setStatus( statusText.setId( "ACT" ) );

        text.setId( json.mainText.id );
        text.setName( json.mainText.name );

        fruit.setTexts( [ text ] );

		if ( !len( json.id ) ) {
			var messageId = "fruit.created";
			var thisId    = super.fire( "fruit.create", [ fruit ] )
		} else {
			var messageId = "fruit.updated";
			var thisId    = super.fire( "fruit.update", [ fruit ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
        
        var result = super.getResult();
        var list = GetHTTPRequestData().content;
        var messageId = "fruit.deletedAllRecords";

        var errors = [];
        var payload = "";

        var ids = ListToArray( list );

        for( var id in ids ) {
            var outcome = super.fire( "fruit.delete", [ id ] );

            if( outcome.getStatus() == "ERROR"  ) {
                errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
            }

        }

        if( errors.len() ) {
            messageId = "fruit.deletedNotAllRecords"
            payload = { "errors": errors } ;
        }

        var message = super.completeMessage( messageId );

        result.setData( { "message" = message, "payload" =  payload } );
        
		event.setValue( "result", result );
	}    

    function addItem( event, rc, prc ){

        var result = super.getResult();
        var attribute = super.fire( "attribute.get", [ rc.attributeId ] );

        param rc.id = '_';          //Current fruit
        param rc.parentId = 0;      //Parent item, if exists
        param rc.attributeId = 0;   //To add items ​​to this attribute

        ```
        <cftransaction>
        
            <cfquery datasource="apirone">
                DELETE FROM product_items
                WHERE 
                    fruit_id = <cfqueryparam cfsqltype="Varchar" value="#rc.id#">::uuid
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
                        fruit_id,
                        attribute_value_id,
                        orderby,
                        parent_id
                    )
                    VALUES (
                        <cfqueryparam cfsqltype="Varchar" value="#rc.id#">::uuid,
                        <cfqueryparam cfsqltype="Integer" value="#item.getId()#">,
                        <cfqueryparam cfsqltype="Integer" value="#item.getOrderBy()#">,
                        #( Val(rc.parentId) ? rc.parentId : 'NULL' )#
                    )
                </cfquery>
                
            </cfloop>

        </cftransaction>

        ```

        var message = super.completeMessage( "fruit.itemsAdded" );

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
            WHERE fruit_id IN ( #rc.items# )
        </cfquery>

        ```

        var message = completeMessage( "fruit.itemsDeleted" );

        result.setData( { "message" = message } );

        event.setValue("result", result);

    }

    function listItems( event, rc, prc ){

        var data = [];
        var result = super.getResult();

        var  items = super.fire("ProductItem.getFlatTree", { fruitId = rc.id } );

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

}
