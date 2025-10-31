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

    var items = NM.kendo.dataSource( { url: "/manager/ajax/products/" + AP.page.productId + "/items?missingValues=false" } );

    var viewModel = kendo.observable( {

        items: items,

        openComponentsList: function( event ) {

            var element = $( event.currentTarget );

            var value = {
                type: "signageItemProduct",
                productItem: {
                    id: event.data.id,
                    attribute: {
                        id: event.data.attribute.id,
                        name: event.data.attribute.name,
                    },
                    attributeValue: {
                        id: event.data.attributeValue.id,
                        rawValue: {
                            id: event.data.attributeValue.rawValue.id,
                            name: event.data.attributeValue.rawValue.name,
                        },
                    },
                },
                signageConfigItem: AP.page.signageConfigItem
            };

            componentApp.open( value );

            return false;
        },

        changeUri: function( event ) {

            var thisForm = fields.configRow;

            var itemEle = thisForm.find( "[name=itemId]" );

            if ( AP.page.selectedProductId ) {
                window.location.href = "/manager/signages/rows-config-item/" + itemEle.val()  + "/product/" + AP.page.selectedProductId;
            }

            return false;

        },

        changeProduct: function( event ) {

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
                    AP.page.selectedProductId = product.id;
                    found = true;
                }
            } );

            if ( !found ) {
                thisButton.val( "" );
                thisButton.attr( "style", "border: 1px solid Red !Important" );
            }

        },

    } );

    pub.init = function() {

        AP.page.selectedProductId = AP.page.productId;

        kendo.bind( fields.rootDetail, viewModel );

    };

    return pub;
} () );
