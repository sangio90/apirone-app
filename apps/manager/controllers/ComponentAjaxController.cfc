component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        param rc.by = "";

        var data = [];
        var result = super.getResult();

        var params = {};

        switch ( rc.by ) {
            case "combination":
                params = { combinationId = rc.combinationId };
                break;

            case "item":
                params = { roductItemId = rc.itemId };
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

            default: 
                throw (type="apirone.error.TypeSearchNotValid", message="Type search [#rc.by#] not valid");
                break;
        }

        var  items = super.fire( "component.list", params );

        for( var item in items ) {

            var row = {
                "quantity" = item.getQuantity(),
                "rawProduct" = {
                    "id" = item.getProduct().getId(),
                    "name" = item.getProduct().getName(),
                    "processingType" = {
                        "id" = item.getProduct().getProcessingType().getId(),
                        "name" = item.getProduct().getProcessingType().getName()
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

            case "fruitItem":
                params = { fruitProductItemId = rc.itemId };
                break;

            default: 
                throw (type="apirone.error.TypeSaveNotValid", message="Type save [#rc.typeId#] not valid");
                break;
        }

        for( var thisComponent in components ) {

            var color   = super.bean("Color");
            var product = super.bean("RawProduct");
            var variant = super.bean("Variant");

            variant.setId( thisComponent.variant.id )
            color.setId( thisComponent.color.id )
            product.setId( thisComponent.product.id )

            component.setProduct( product );
            component.setColor( color );
            component.setVariant( variant );
            component.setQuantity( thisComponent.quantity );

            super.fire( "Component.create", [ component ] );

        }

        var message = completeMessage( "combination.componentAdded" );

        result.setData( { "message" = message } );

        event.setValue( "result", result );

    }

}
