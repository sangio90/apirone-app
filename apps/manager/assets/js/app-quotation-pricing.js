AP.namespace( "quotation" );

Object.assign( AP.quotation.fields, {
    boxPricing: $( "#totalsFloatingTab" )
} );

$( document ).ready( function() {

    if ( AP.quotation.fields.boxPricing.length ) {

        AP.quotation.pricing.init();
    }

} );


AP.quotation.pricing = ( function() {
    var defaultItems = {
        data: {
            id: "",
        }
    };

    var fields = AP.quotation.fields;

    var viewModel = kendo.observable( {

        items: [
            { name: "Frutto 1", amount: 10.5 },
            { name: "Frutto 2", amount: 10.3 },
            { name: "Frutto 3", amount: 10.4 }
        ]

    } );

    var pub = {};

    pub.init = function() {

        console.log( "pricing:init" );

    	kendo.bind( AP.quotation.fields.boxPricing, viewModel );

    };

    return pub;
} () );

