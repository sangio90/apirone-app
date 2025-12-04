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
                    id: "C" // calculated
                },

                total: "0",
                lines: [], // es. { name: "Frutto 1", amount: 10.5 },
            },
        },

        changeMethod: function( event ) {

            var ele = $( event.currentTarget );

            var value = ele.val();
            var input = fields.boxPricing.find( "#input-total" );

            if ( value == "C" ) {
                this.update();

                input.prop( "readonly", true );
            } else {
                input.prop( "readonly", false );
            }

        },

        /*
        formatTotal: function( event ) {

            viewModel.set( "a" );

            console.log( "formatTotal:event", event );

            if ( event ) {
                NM.kendo.formatCurrency( event );
            }

        },
        */

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
    } );

    pub.update = function() {

    	viewModel.update();

    };

    pub.init = function( itemId ) {

        kendo.bind( AP.quotation.fields.boxPricing, viewModel );

        AP.quotation.fields.boxPricing.show();

        viewModel.set( "item.id", itemId );

    };

    pub.getData = function( itemId ) {

        return viewModel.get( "pricing" );

    };

    return pub;
} () );
