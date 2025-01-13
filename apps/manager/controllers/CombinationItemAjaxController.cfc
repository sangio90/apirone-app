component extends="com.apirone.core.controller.AbsController" {

    function listComponents( event, rc, prc ){

        var data = [];
        var result = super.getResult();

        var  items = super.fire("CombinationComponent.list", { combinationItemId = rc.id } );

        for( var item in items ) {

            var row = {
                "quantity" = item.getQuantity(),
                "comp" = {
                    "id" = item.getComponent().getId(),
                    "name" = item.getComponent().getName(),
                    "processingType" = {
                        "id" = item.getComponent().getProcessingType().getId(),
                        "name" = item.getComponent().getProcessingType().getName()
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

        var combinationComponent = super.bean("CombinationComponent");
        var component = super.bean("Component");
        var variant = super.bean("Variant");
        var color = super.bean("Color");

        for( var thisComponent in components ) {

            variant.setId( thisComponent.variant.id )
            color.setId( thisComponent.color.id )
            component.setId( thisComponent.comp.id )

            combinationComponent.setComponent( component );
            combinationComponent.setColor( color );
            combinationComponent.setVariant( variant );
            combinationComponent.setQuantity( thisComponent.quantity );
            
            super.fire( "CombinationItem.addComponent", { combinationItemId = itemId, combinationComponent = combinationComponent } );

        }

        var message = completeMessage( "combination.componentAdded" );

        result.setData( { "message" = message } );

        event.setValue( "result", result );

    }

}
