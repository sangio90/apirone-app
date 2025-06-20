component extends="com.apirone.core.controller.AbsController" {

    function listItems( event, rc, prc ){

        var result = getFlatTree( combinationId=rc.id, includeMissingValues=true );

        event.setValue("result", result);

    }

    function listItemsForSort( event, rc, prc ){

        var result = getFlatTree( combinationId=rc.id, includeMissingValues=false );

        event.setValue("result", result);

    }

	function listAttributesForSort( event, rc, prc ) {

		var attrs = [];

		private Boolean function exists( required attributeId, required attrs ) {

			for( var attr in arguments.attrs ) {
				if( attr.id == arguments.attributeId ) {
					return true;
				}
			}

			return false;
		}

        var rows = getFlatTree( combinationId=rc.id, includeMissingValues=false );

		for( var row in rows.getData() ) {

			if( !exists( row.attribute.id, attrs ) ) {

                var item = row.attribute;
                
                item["level"]   = row.level;
                item["spaces"]  = RepeatString( "&nbsp;&nbsp;&nbsp;&nbsp;", row.level );
                item["shortId"] = Right( item.id, 5 );

				attrs.add( item );

			}


		}

        for( var thisAttr in attrs ) {
            dump("#thisAttr.level# #thisAttr.id# #thisAttr.name#")
        }


        event.setValue("result", attrs);

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

    function addValue( event, rc, prc ){

        var json = DESerializeJSON( GetHTTPRequestData().content );

        var data = [];
        var result = super.getResult();

        var item = super.bean("ProductItem");
        var value = super.bean("AttributeValue");
        var status = super.bean("Status");

        status.setId( "ACT" ); //Active
        value.setId( json.attributeValue.id );
        
        item.setOrderBy( json.orderBy );

        item.setCombinationId( rc.id );
        item.setAttributeValue( value );
        item.setStatus( status );

        var newId = super.fire("ProductItem.create", { productItem = item } );

        var message = completeMessage( "combination.valueAdded" );

        result.setData( { "message" = message, "payload" = { "id": newId } } );

        event.setValue("result", result);

    }

    function sortItems( event, rc, prc ){

        var result = super.getResult();

        var list = ReplaceList( GetHTTPRequestData().content, "[,]", "" ); //string: [1,2,3] with brackets.
        var items = ListToArray( list );
        
        //dump(items);
        //abort;

        var json = DESerializeJSON( GetHTTPRequestData().content );

        var orderby = 10;

        for( var item in items ) {

            var bean = super.fire("ProductItem.get", { productItemId = item } );
            bean.setOrderBy( orderby );
            
            super.fire("ProductItem.update", { productItem = bean } );

            orderby = orderby+10;

        }

        var message = completeMessage( "combination.valuesReordered" );

        result.setData( { "message" = message } );

        event.setValue("result", result);

    }


    /*
        private methods
    */

    private function getFlatTree( combinationId, includeMissingValues=true ){

        var data = [];
        var result = super.getResult();

        var items = super.fire("ProductItem.getFlatTree", { combinationId = arguments.combinationId, includeMissingValues=arguments.includeMissingValues } );

        for( var item in items ) {

            var row = super.getDataMapper().convert( item, "ProductItem", true );

            row["spaces"] = RepeatString( "&nbsp;&nbsp;&nbsp;&nbsp;", item.getLevel() );

            data.add( row );

        }

        result.setTotal( data.len() );
        result.setCount( data.len() );
        result.setData( data );

        return result;

    }

}
