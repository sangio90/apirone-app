component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        param rc.by = "";

        var data = [];
        var result = super.getResult();

        var params = {};

        var params = getParams( typeId = rc.by, rc = rc );

        var items = super.fire( "component.list", params );

        for( var item in items ) {

            var product = item.getRawProduct();

            var row = {
                "id" = item.getId(),
                "quantity" = item.getQuantity(),
                "rawProduct" = {
                    "id" = product.getId(),
                    "name" = product.getName(),
                    "processingType" = {
                        "id" = product.getProcessingType().getId(),
                        "name" = product.getProcessingType().getName()
                    },
                    "measurementUnit" = {
                        "id" = product.getMeasurementUnit().getId(),
                        "name" = product.getMeasurementUnit().getName()
                    }
                },
                "variant" = {
                    "id" = item.getVariant().getId(),
                    "name" = item.getVariant().getName()
                },
                "color" = {
                    "id" = item.getColor().getId(),
                    "name" = item.getColor().getName()
                }
            }

            data.add( row );

        }

        result.setTotal( items.len() );
        result.setCount( items.len() );
        result.setData( data );

        event.setValue( "result", result );

    }

    function save( event, rc, prc ){

        var result = super.getResult();

        var components = DeserializeJSON( GetHTTPRequestData().content );

        switch ( rc.by ) {
            case "combination":

                var component = super.bean("ComponentCombination");
                var combination = super.bean("Combination");

                component.setCombination( combination.setId( rc.combinationId ) );

                break;

            case "item":

                var component = super.bean("ComponentProductItem");
                var item = super.bean("ProductItem");

                component.setProductItem( item.setId( rc.itemId ) );

                break;
                
            case "lineSize":
                var component = super.bean("ComponentLineSize");
                
                var size = super.bean("size");
                var line = super.bean("line");

                component.setLine( line.setId( rc.lineId ) );
                component.setSize( size.setId( rc.sizeId ) );

                break;

            case "fruit":
                
                var component = super.bean("ComponentFruit");
                var fruit = super.bean("fruit");

                component.setFruit( fruit.setId( rc.fruitId ) );

                break;

            case "attributeValue":
                
                var component = super.bean("ComponentAttributeValue");
                var value = super.bean("AttributeValue");

                component.setAttributeValue( value.setId( rc.attributeValueId ) );

                break;

            case "fruitItem":
                //params = { fruitProductItemId = rc.itemId };
                //break;

            default: 
                throw( type="apirone.error.TypeSaveNotValid", message="Type save [#rc.typeId#] not valid" );
                break;
        }

        var params = getParams( typeId = rc.by, rc = rc );
        var oldItems = super.fire( "component.list", params );

        cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# currentItems: #oldItems.len()#");

        var itemExists = [];

        for( var thisComponent in components ) {

            if ( thisComponent.id != "" ) {
                ArrayAppend( itemExists, thisComponent.id );
            }

            var color      = super.bean("Color");
            var rawProduct = super.bean("RawProduct");
            var variant    = super.bean("Variant");

            variant.setId( thisComponent.variant.id )
            color.setId( thisComponent.color.id )
            rawProduct.setId( thisComponent.rawProduct.id )

            component.setId( thisComponent.id );
            component.setRawProduct( rawProduct );
            component.setColor( color );
            component.setVariant( variant );
            component.setQuantity( thisComponent.quantity );

            super.fire( "component.create", [ component ] );

        }

        //cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# oldItems: #oldItems.len()#");
        //cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# itemExists: #ArrayToList( itemExists )#");

        for( var oldItem in oldItems ) {

            //cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# oldItems: this: #oldItem.getId()#");
            
            if( !itemExists.find( oldItem.getId() ) ) {

                //cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# oldItems: delete: #oldItem.getId()#");

                super.fire( "component.delete", { componentId = oldItem.getId() } );
            }
        
        }

        var message = completeMessage( "combination.componentAdded" );

        result.setData( { "message" = message } );

        event.setValue( "result", result );

    }

    function getParams( required String typeId, required Struct rc ){

        var params = {}

        switch ( arguments.typeId ) {
            case "combination":
                params = { combinationId = rc.combinationId };
                break;

            case "item":
                params = { productItemId = rc.itemId };
                break;
                
            case "lineSize":
                params = { lineId = rc.lineId, sizeId = rc.sizeId };
                break;

            case "fruit":
                params = { fruitId = rc.fruitId };
                break;

            case "fruitItem":
                params = { fruitProductItemId = rc.itemId };
                break;

            case "attributeValue":
                params = { attributeValueId = rc.attributeValueId };
                break;

            default: 
                throw (type="apirone.error.TypeSearchNotValid", message="Type search [#rc.by#] not valid");
                break;
        }

        return params;

    }

}
