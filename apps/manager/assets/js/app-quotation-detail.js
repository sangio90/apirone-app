AP.namespace( "quotation" );

Object.assign( AP.quotation.fields, {
    headerRoot: $( "#quotation-header-root" ),
} );

$( document ).ready( function() {
    if ( AP.quotation.fields.headerRoot.length ) {
        AP.quotation.header.init();
    }
} );

AP.quotation.header = ( function() {
    var pub = {};

    var fields = AP.quotation.fields;

    var viewModel = kendo.observable( {
        rows: [],

        search: function( event ) {

            return false;
        },

        save: function() {

            document.getElementById( "quotation-header-form" ).submit();

            // window.location.href = "/manager/quotations/new";
        },
    } );

    pub.init = function() {
        kendo.bind( AP.quotation.fields.headerRoot, viewModel );

        console.log( "quotation.header:init" );

    };

    return pub;
}() );