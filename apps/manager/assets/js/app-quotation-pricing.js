AP.namespace( "quotation" );

Object.assign( AP.quotation.fields, {
    boxPricing: $( "#quotation-totals-item" )
} );

$( document ).ready( function() {

    console.log( "AP.quotation.fields.boxPricing", AP.quotation.fields.boxPricing );

    if ( AP.quotation.fields.boxPricing.length ) {

        // AP.quotation.pricing.init();
    }

} );


AP.quotation.pricing = ( function() {

    var pub = {};
    var fields = AP.quotation.fields;

    var viewModel = kendo.observable( {

        item: {
            id: ""
        },

        pricing: {
            data: {
                discount1: "",
                discount2: "",

                method: {
                    id: "C"
                },

                total: "0",
                lines: [], // es. { name: "Frutto 1", amount: 10.5 },
            },
        },

        changePriceMethod: function( event ) {

            console.log( "event", event );

            if ( event.id ) {

            }

        },

        change: function( event ) {

            console.log( "change:event", event );

        },

        update: function( event ) {

            var status = $( "#quotation-totals-item-loading" );
            status.html( "<img src='/assets/main/img/ajax-loading-blu.svg' width='20' height='20'>" );

            var data = AP.plate.modal.getVM().detailForm;
            data.data.pricing = viewModel.get( "pricing.data" );

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/quotation-items/pricing",
                data: JSON.stringify( data.data ),
                callback: {
                    done: function( xhr ) {
                        if ( xhr.data ) {

                            status.html( "" );

                            viewModel.set( "pricing.data", xhr.data );
                            // viewModel.set( "pricing.data", xhr.data );
                        }
                    }
                }
            } );

        },

        collapseTotals: function( event ) {

            var container = $( "#quotation-totals-item-content" );
            var symbol = $( "#qt-item-totals-symbol" );

            if ( container.is( ":hidden" ) ) {
                container.show();
                symbol.text( "▼" );
            } else {
                container.hide();
                symbol.text( "▲" );
            }

            return false;
        }

    } );

    viewModel.bind( "change", function( event ) {

        var value = this.get( event.field );
        var input = fields.boxPricing.find( "#input-total" );

        console.log( "input", input );

        if ( value == "A" ) {
            input.prop( "readonly", true );

            this.update();

        } else {
            input.prop( "readonly", false );
        }

    } );

    pub.update = function() {

    	viewModel.update();

    };

    pub.init = function( itemId ) {

        console.log( "pricing" );

        kendo.bind( AP.quotation.fields.boxPricing, viewModel );

        AP.quotation.fields.boxPricing.show();

        viewModel.set( "item.id", itemId );

    };

    return pub;
} () );

