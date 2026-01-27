AP.namespace( "quotation" );

Object.assign( AP.quotation.fields, {
    // boxPricing: $( "#quotation-totals" ),
    // boxItemPricing: $( "#quotation-totals" ),
    boxItemPricing: $( "#quotation-item-pricing-box" ),
    boxTotalPricing: $( "#quotation-total-pricing-box" ),
} );

AP.quotation.itemPricing = ( function() {

    var pub = {};
    var fields = AP.quotation.fields;

    var defaultForm = {
        data: {
            id: "",
            quantity: 1,
            discount1: "",
            discount2: "",
            method: {
                id: "C" // calculated
            },
            lines: [], // es. { name: "Frutto 1", amount: 10.5 },
            total: 0,
        }
    };

    var viewModel = kendo.observable( {

        pricing: defaultForm,

        changeMethod: function( event ) {

            var ele = $( event.currentTarget );

            var value = ele.val();
            var price = fields.boxPricing.find( "#input-item-total" );

            if ( value == "C" ) {
                this.updateItem();

                price.prop( "readonly", true );
            } else {
                price.prop( "readonly", false );
            }

        },

        update: function( event ) {

            var status = $( "#quotation-item-pricing-status" );
            status.html( "<img src='/assets/main/img/ajax-loading.svg' width=20 height=20>" );

            var data = viewModel.get( "detailForm.data" );

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/quotation-items/pricing",
                data: JSON.stringify( data ),
                callback: {
                    done: function( xhr ) {
                        if ( xhr.data ) {

                            status.html( "" );
                            viewModel.set( "detailForm.data.pricing", xhr.data );

                        }
                    }
                }
            } );

        },

    } );


    pub.update = function() {

    	viewModel.update();
    };

    pub.init = function( id, data ) { // type: item, quotation

        kendo.bind( fields.boxPricingItem, viewModel );

        if ( data ) {
            viewModel.set( "pricing", data );
        } else {
            viewModel.set( "pricing", defaultForm );
        }

        // viewModel.set( "pricing.data.id", id );
        // viewModel.set( "pricing.data.id", id );

        // fields.boxPricing.show();

    };

    pub.getData = function( itemId ) {

        // var model = getCurrentViewModel();
        return viewModel.get( "pricing" );

    };

    return pub;
} () );

AP.quotation.totalPricing = ( function() {

    var pub = {};
    var fields = AP.quotation.fields;

    var isCollapsed = AP.getUserPref( "quotation.totalPricing.isBoxCollapsed", false );

    var collapseBox = function() {

        var status = viewModel.get( "detail.isCollapsed" );
        var newStatus = !status;

        viewModel.set( "detail.isCollapsed", newStatus );

        var newSymbol = newStatus ? "▲" : "▼";
        viewModel.set( "detail.symbol", newSymbol );

        AP.setUserPref( "quotation.pricing.isCollapsed", newStatus );

        return false;

    };

    var viewModel = kendo.observable( {

        detail: {
            title: "",
            isCollapsed: isCollapsed,
            symbol: isCollapsed ? "▲" : "▼",
        },

        pricing: {
            counters: {
                plates: 0,
                signages: 0,
                accessories: 0
            },
            data: {
                discount1: "",
                discount2: "",

                method: {
                    id: "C" // calculated
                },

                shippingCost: 0,
                totalGoods: 0,
                total: 0
            },
        },

        getFormattedTotal: function() {

            var value = this.get( "pricing.data.total" );

            if( value ) { console.log( "getFormattedTotal:value", value ); }

            return value;

        },

        init: function( event ) {

            var status = $( "#quotation-totals-general-loading" );
            status.html( "<img src='/assets/main/img/ajax-loading-blu.svg' width=20 height=20>" );

            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/" + AP.page.quotation.id + "/totals",
                callback: {
                    done: function( xhr ) {

                        status.html( "" );

                        viewModel.set( "pricing.counters", xhr.data.counters );
                        viewModel.set( "pricing.data", xhr.data.pricing );
                    }
                }
            } );

        },

        changeMethod: function( event ) {

            var ele = $( event.currentTarget );

            var value = ele.val();
            var input = fields.boxTotalPricing.find( "#input-total" );

            if ( value == "C" ) {
                this.update();

                input.prop( "readonly", true );
            } else {
                input.prop( "readonly", false );
            }

        },

        updateTotals: function( event ) {

            var status = $( "#quotation-totals-general-loading" );
            status.html( "<img src='/assets/main/img/ajax-loading-blu.svg' width=20 height=20>" );

            var data = AP.plate.modal.getVM().detailForm;
            data.data.pricing = viewModel.get( "pricing.data" );

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/quotations/" + AP.page.quotation.id + "/totals",
                data: JSON.stringify( data.data ),
                callback: {
                    done: function( xhr ) {

                        status.html( "" );

                        viewModel.set( "pricing.counters", xhr.data.counters );
                        viewModel.set( "pricing.data", xhr.data.pricing );
                    }
                }
            } );

        },

        collapseTotals: function() {
            collapseBox();
        }

    } );

    pub.updateTotals = function() {
    	viewModel.updateTotals();
    };

    pub.init = function() { // type: item, quotation

        kendo.bind( fields.boxTotalPricing, viewModel );

        viewModel.set( "detail.title", "Totali preventivo" );

        fields.boxTotalPricing.show();

    };

    pub.getData = function( itemId ) {

        // var model = getCurrentViewModel();
        return viewModel.get( "pricing" );

    };

    return pub;
} () );