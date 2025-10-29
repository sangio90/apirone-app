AP.namespace( "signageConfigItem" );

Object.assign( AP.signageConfigItem.fields, {
    detailRoot: $( "#signage-config-item-root" ),
} );

$( document ).ready( function() {
    if ( AP.signageConfigItem.fields.detailRoot.length ) {
        AP.signageConfigItem.detail.init();
    }
} );

AP.signageConfigItem.detail = ( function() {

    var pub = {};

    var componentApp = AP.component.modal;
    var fields = AP.signageConfigItem.fields;

    var viewModel = kendo.observable( {

        openComponentsList: function( event ) {

            var value = {
                type: "signageConfigItemItem",
                signageConfigItemItem: {
                    id: event.data.id,
                },
            };

            componentApp.open( value );

            return false;
        },
    } );

    pub.init = function() {

        kendo.bind( AP.signageConfigItem.fields.detailRoot, viewModel );

    };

    return pub;
}() );

