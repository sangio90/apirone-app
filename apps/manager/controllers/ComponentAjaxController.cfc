component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var rc.typeId = "____";

        var data = [];
        var result = super.getResult();

        var params = {};

        dump(rc);
        abort;

        if( rc.typeId == "combination" ) {
            params = { combination = rc.combinationId };
        }

        if( rc.typeId == "item" ) {
            params = { combinationItemId = rc.itemId };
        }

        if( rc.typeId == "lineSize" ) {
            params = { lineId = rc.lineId, sizeId = rc.sizeId };
        }

        dump(rc);

        abort;

        var  items = super.fire( "Component.list", params );

        for( var item in items ) {

            var row = {
                "quantity" = item.getQuantity(),
                "product" = {
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

        var itemId = rc.id;

        var color   = super.bean("Color");
        var product = super.bean("Product");
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
            
            super.fire( "CombinationItem.addComponent", { combinationItemId = itemId, combinationComponent = combinationComponent } );

        }

        var message = completeMessage( "combination.componentAdded" );

        result.setData( { "message" = message } );

        event.setValue( "result", result );

    }

}
