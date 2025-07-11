component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        param rc.by = "";

        var data = [];
        var result = super.getResult();

        var params = getParams( typeId = rc.by, rc = rc );

        var items = super.fire( "component.list", params );

        for( var item in items ) {

            var row = convertComponent( item );
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
            case "product":

                var component = super.bean("ComponentProduct");
                var product = super.bean("Product");

                component.setProduct( product.setId( rc.productId ) );

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

                /*
            case "fruit":
                
                var component = super.bean("ComponentFruit");
                var fruit = super.bean("fruit");

                component.setFruit( fruit.setId( rc.fruitId ) );

                break;
                */

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

        var itemExists = [];

        for( var thisComponent in components ) {

            if ( thisComponent.id != "" ) {
                ArrayAppend( itemExists, thisComponent.id );
            }

            if( thisComponent.typeId == "base" ) {

                var override = super.bean("ComponentOverride");
                
                override.setId( thisComponent.override.id );
                override.setDeleted( thisComponent.override.deleted );  
                override.setQuantity( thisComponent.override.quantity );  
                override.setComponentId( thisComponent.id );  
                override.setProductItemId( component.getProductItem().getId() );  

                cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# override: #thisComponent.override.id#");
                
                if( Len( thisComponent.override.id ) ) {
                    super.fire( "ComponentOverride.update", [ override ] );
                    cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# override: create: #thisComponent.override.id#");
                } else {
                    super.fire( "ComponentOverride.create", [ override ] );
                    cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# override: update: #thisComponent.override.id#");
                }                

            } else {

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

                if( Len( component.getId() ) ) {
                    super.fire( "component.update", [ component ] );
                } else {
                    super.fire( "component.create", [ component ] );
                }                

            }

        }

        for( var oldItem in oldItems ) {

            if( !itemExists.find( oldItem.getId() ) ) {
                super.fire( "component.delete", { componentId = oldItem.getId() } );
                cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# delete oldItems: this: #oldItem.getId()#");

            }
        
        }

        var message = completeMessage( "product.componentAdded" );

        result.setData( { "message" = message } );

        event.setValue( "result", result );

    }


    /*
        private methods
    */

    private function convertComponent( required Struct component ){

        //TODO: move to DataMapper

        var product = component.getRawProduct();

        var row = {
            "id" = component.getId(),
            "typeId" = component.getTypeId(),
            "quantity" = component.getQuantity(),
            "override" = {
                "id" = component?.getOverride()?.getId(),
                "deleted" = component?.getOverride()?.getDeleted(),
                "quantity" = component?.getOverride()?.getQuantity()
            },
            "totalQuantity" = component.getTotalQuantity(),
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
                "id" = component.getVariant().getId(),
                "name" = component.getVariant().getName()
            },
            "color" = {
                "id" = component.getColor().getId(),
                "name" = component.getColor().getName()
            }
        }

        return row;

    }

    private function getParams( required String typeId, required Struct rc ){

        var params = {}

        switch ( arguments.typeId ) {
            case "product":
                params = { productId = rc.productId };
                break;

            case "item":
                params = { productItemId = rc.itemId, includeBaseAttributeComponents = true };
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
                params = { attributeValueId = rc.attributeValueId, includeBaseAttributeComponents = false };
                break;

            default: 
                throw( type="apirone.error.TypeSearchNotValid", message="Type search [#rc.by#] not valid" );
                break;
        }

        return params;

    }

}
