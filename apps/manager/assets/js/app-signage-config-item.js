AP.namespace( "signageConfigItem" );

Object.assign( AP.signageConfigItem.fields, {
    rootDetail: $( "#signage-config-item-detail-root" ),
    configRow: $( "#signage-config-item-change-form" )
} );

$( document ).ready( function() {
    if ( AP.signageConfigItem.fields.rootDetail.length ) {
        AP.signageConfigItem.items.init();
    }
} );

AP.signageConfigItem.items = ( function() {
    var pub = {};

    var fields = AP.signageConfigItem.fields;
    var componentApp = AP.component.modal;

    var items = NM.kendo.dataSource( { url: "/manager/ajax/products/" + AP.page.productId + "/items" } );

    var viewModel = kendo.observable( {

        items: items,

        getAttributeName: function( event ) {
            var text = AP.util.getTextItem( event.texts );

            return text.name;
        },

        openComponentsList: function( event ) {

            var element = $( event.currentTarget );

            if ( !element.attr( "data-type" ) ) {
                console.error( "ERROR. Set data-type attribute in currentTarget" );
                return;
            }

            var type = element.data( "type" );

            switch ( type ) {
            case "catalogBundle":
                var value = {
                    type: "catalogBundle",
                    model: {
                        id: element.data( "model-id" ),
                        name: element.data( "model-name" ),
                    },
                    line: {
                        id: element.data( "line-id" ),
                        name: element.data( "line-name" ),
                    },
                };

                break;

            case "item":
                var value = {
                    type: "item",
                    item: {
                        id: event.data.id,
                    },
                    attribute: {
                        id: event.data.attribute.id,
                        name: event.data.attribute.name,
                    },
                    attributeValue: {
                        id: event.data.attributeValue.id,
                        // name: event.data.attributeValue.name,
                        rawValue: {
                            id: event.data.attributeValue.rawValue.id,
                            name: event.data.attributeValue.rawValue.name,
                        },
                    },
                };

                break;

            case "product":
                var value = {
                    type: "product",
                    product: {
                        id: element.data( "product-id" ),
                        name: element.data( "product-name" ),
                    },
                };

                break;

            default:
            }

            componentApp.open( value );

            return false;
        },

        changeUri: function( event ) {

            var thisButton = $( event.currentTarget );

            var thisForm = fields.configRow;
            var found = false;

            var finishEle = thisForm.find( "[name=finishId]" );
            var modelEle = thisForm.find( "[name=modelId]" );

            finishEle.css( "border", "1px solid #ced4da" );
            modelEle.css( "border", "1px solid #ced4da" );

            var lineId = AP.page.lineId;
            var modelId = modelEle.val();
            var finishId = finishEle.val();

            var products = AP.page.products;

            products?.forEach( function( product ) {

                if ( lineId == product.line.id
                    && finishId == product.finish.id
                    && modelId == product.model.id ) {
                    found = true;
                    window.location.href = "/manager/signages/rows-config-item/" + AP.page.signageConfigItemId + "/product/" + product.id;
                }
            } );

            if ( !found ) {
                thisButton.val( "" );
                thisButton.attr( "style", "border: 1px solid Red !Important" );
            }

        },

    } );

    pub.init = function() {

        kendo.bind( fields.rootDetail, viewModel );

    };

    return pub;
} () );
