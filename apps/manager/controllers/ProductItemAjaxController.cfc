component extends="com.apirone.core.controller.AbsController" {

    function listComponents( event, rc, prc ){

        var data = [];
        var result = super.getResult();

        var  items = super.fire("CombinationComponent.list", { roductItemId = rc.id } );

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

    function saveComponents( event, rc, prc ){

        var result = super.getResult();

        var components = DeserializeJSON( GetHTTPRequestData().content );

        var itemId = rc.id;

        var color   = super.bean("Color");
        var product = super.bean("RawProduct");
        var variant = super.bean("Variant");

        var combinationComponent = super.bean("Combination");

        for( var thisComponent in components ) {

            variant.setId( thisComponent.variant.id )
            color.setId( thisComponent.color.id )
            product.setId( thisComponent.comp.id )

            combinationComponent.setProduct( product );
            combinationComponent.setColor( color );
            combinationComponent.setVariant( variant );
            combinationComponent.setQuantity( thisComponent.quantity );
            
            super.fire( "ProductItem.addComponent", { roductItemId = itemId, combinationComponent = combinationComponent } );

        }

        var message = completeMessage( "combination.componentAdded" );

        result.setData( { "message" = message } );

        event.setValue( "result", result );

    }

}
