component extends="com.apirone.core.controller.AbsController" accessors="true" {
	property name="dao" inject="ProductItemDAO";

    function listComponents( event, rc, prc ){

        var data = [];
        var result = super.getResult();

        var  items = super.fire("ProductComponent.list", { productItemId = rc.id } );

        for( var item in items ) {

            var row = {
                "quantity" = item.getQuantity(),
                "rawProduct" = {
                    "id" = item.getProduct().getId(),
                    "name" = item.getProduct().getName(),
                    "processingType" = {
                        "id" = item.getProduct().getProcessingType().getId(),
                        "name" = item.getProduct().getProcessingType().getName()
                    },
                    "measumentUnit" = {
                        "id" = item.getProduct().getMeasumentUnit().getId(),
                        "name" = item.getProduct().getMeasumentUnit().getName()
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

        var productComponent = super.bean("Product");

        for( var thisComponent in components ) {

            variant.setId( thisComponent.variant.id )
            color.setId( thisComponent.color.id )
            product.setId( thisComponent.comp.id )

            productComponent.setProduct( product );
            productComponent.setColor( color );
            productComponent.setVariant( variant );
            productComponent.setQuantity( thisComponent.quantity );

            super.fire( "ProductItem.addComponent", { productItemId = itemId, productComponent = productComponent } );

        }

        var message = completeMessage( "product.componentAdded" );

        result.setData( { "message" = message } );

        event.setValue( "result", result );

    }

    public function productItemsByProduct( event, rc, prc ) {

        var result = super.getResult();
	    var memy = super.getMementify();
        var transformer = super.transformer( "ProductItem" );

		var productId = rc.productId;

        var params = {
            productId = productId,
            originId = StructKeyExists(rc, "originId") ? rc.originId : null
        };

        var data = getDao().findComplete( argumentCollection = params );

		//var items = super.fire( "ProductItem.list", params );
	    // var data = ( memy.convertList( a, "treelight" ) );

        // var data = transformer.convertList( items, "tree" );

        var jsonData = serializeJSON(data, "struct")
        var deserializedJsonData = deserializeJSON(jsonData);

		result.setTotal( arrayLen(deserializedJsonData) );
		result.setCount( arrayLen(deserializedJsonData) );
		result.setData( deserializedJsonData );
        //?productId=64c21935-dca1-494b-8640-9ec5f65f25e8&originId=101634

		event.setValue( "result", result );
	}

}
