component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        param rc.typeId = "";

        var data = [];
        var result = super.getResult();

        var params = {};

        if( rc.typeId == "combination" ) {
            params = { combinationId = rc.combinationId };
        }

        if( rc.typeId == "item" ) {
            params = { combinationItemId = rc.itemId };
        }

        if( rc.typeId == "lineSize" ) {
            params = { lineId = rc.lineId, sizeId = rc.sizeId };
        }


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

        if( rc.typeId == "item" ) {

            var component = super.bean("ComponentCombinationItem");
            var item = super.bean("CombinationItem");

            component.setCombinationItem( item.setId( rc.itemId ) );

        }

        if( rc.typeId == "lineSize" ) {

            var component = super.bean("ComponentLineSize");
            
            var size = super.bean("size");
            var line = super.bean("line");

            component.setLine( line.setId( rc.lineId ) );
            component.setSize( size.setId( rc.sizeId ) );

        }

        if( rc.typeId == "combination" ) {

            var component = super.bean("ComponentCombination");
            var combination = super.bean("Combination");

            component.setCombination( combination.setId( rc.combinationId ) );

        }

        for( var thisComponent in components ) {


            var color   = super.bean("Color");
            var product = super.bean("Product");
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
