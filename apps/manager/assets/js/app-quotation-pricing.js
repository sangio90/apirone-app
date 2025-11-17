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

    var fields = AP.quotation.fields;

    var viewModel = kendo.observable( {

        pricing: {
            items: [
                { name: "Frutto 1", amount: 10.5 },
                { name: "Frutto 2", amount: 10.3 },
                { name: "Frutto 3", amount: 10.4 }
            ],

            discounts: {
                value1: "",
                value2: ""
            },

            priceType: {
                id: "F"
            },

            total: "0"
        },

        update: function( event ) {

            console.log( "update", event );

            var data = AP.plate.modal.getVM().detailForm;

            console.log( "data", data );

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/quotation-items/000000/total",
                data: JSON.stringify( data.data ),
                callback: {
                    done: function( xhr ) {
                        if ( xhr.data ) {
                            viewModel.get( "items", xhr.data );
                        }
                    }
                }
            } );

        }

    } );

    var pub = {};

    pub.update = function() {

    	viewModel.update();

    };

    pub.init = function() {

    	kendo.bind( AP.quotation.fields.boxPricing, viewModel );

    };

    return pub;
} () );

