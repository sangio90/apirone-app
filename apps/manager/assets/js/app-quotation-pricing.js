AP.namespace( "quotation" );

Object.assign( AP.quotation.fields, {
    boxPricing: $( "#quotation-totals" ),
    boxItemPricing: $( "#quotation-totals-item-content" ),
    boxGeneralPricing: $( "#quotation-totals-general-content" ),
} );

AP.quotation.pricing = ( function() {

    var pub = {};
    var fields = AP.quotation.fields;
    var type = undefined; // set by init()

    var getCurrentViewModel = function() {

        if ( type == "item" ) {
            return viewModelItem;
        }

        return viewModelGeneral;

    };

    var getCommonData = function() {

        var isCollapsed = AP.getUserPref( "quotation.pricing.isCollapsed", false );

        return kendo.observable( {
            title: "",
            isCollapsed: isCollapsed,
            symbol: isCollapsed ? "▲" : "▼"
        } );

    };

    var collapseBox = function() {

        var model = getCurrentViewModel();
        var status = model.get( "common.isCollapsed" );
        var newStatus = !status;

        model.set( "common.isCollapsed", newStatus );

        var newSymbol = newStatus ? "▲" : "▼";
        model.set( "common.symbol", newSymbol );

        AP.setUserPref( "quotation.pricing.isCollapsed", newStatus );

        return false;

    };

    var viewModelItem = kendo.observable( {

        common: getCommonData(),

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

        isItem: true,
        isGeneral: false,

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

        updateItem: function( event ) {

            var status = $( "#quotation-totals-item-loading" );
            status.html( "<img src='/assets/main/img/ajax-loading-blu.svg' width=20 height=20>" );

            var data = AP.plate.modal.getVM().detailForm;
            data.data.pricing = viewModelItem.get( "pricing.data" );

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/quotation-items/pricing",
                data: JSON.stringify( data.data ),
                callback: {
                    done: function( xhr ) {
                        if ( xhr.data ) {

                            status.html( "" );

                            viewModelItem.set( "pricing.data", xhr.data );
                        }
                    }
                }
            } );

        },

        collapseTotals: function() {

            collapseBox();
        },

    } );

    var viewModelGeneral = kendo.observable( {

        common: getCommonData(),

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

        isItem: false,
        isGeneral: true,

        init: function( event ) {

            var status = $( "#quotation-totals-general-loading" );
            status.html( "<img src='/assets/main/img/ajax-loading-blu.svg' width=20 height=20>" );

            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/" + AP.page.quotation.id + "/totals",
                callback: {
                    done: function( xhr ) {

                        status.html( "" );

                        viewModelGeneral.set( "pricing.counters", xhr.data.counters );
                        viewModelGeneral.set( "pricing.data", xhr.data.pricing );
                    }
                }
            } );

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

        updateTotals: function( event ) {

            var status = $( "#quotation-totals-general-loading" );
            status.html( "<img src='/assets/main/img/ajax-loading-blu.svg' width=20 height=20>" );

            var data = AP.plate.modal.getVM().detailForm;
            data.data.pricing = viewModelGeneral.get( "pricing.data" );

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/quotations/" + AP.page.quotation.id + "/totals",
                data: JSON.stringify( data.data ),
                callback: {
                    done: function( xhr ) {

                        status.html( "" );

                        viewModelGeneral.set( "pricing.counters", xhr.data.counters );
                        viewModelGeneral.set( "pricing.data", xhr.data.pricing );
                    }
                }
            } );

        },

        collapseTotals: function() {
            collapseBox();
        }

    } );

    pub.updateItem = function() {
    	viewModelItem.update();
    };

    pub.updateTotals = function() {
    	viewModelGeneral.update();
    };

    pub.init = function( id, initType ) { // type: item, quotation

        type = initType; // Imposta la variabile type

        if ( type == "item" ) {
            var model = viewModelItem;
            viewModelItem.set( "item.id", id );
            viewModelItem.set( "common.title", "Dettaglio riga" );
        } else {
            var model = viewModelGeneral;
            viewModelGeneral.set( "common.title", "Totali preventivo" );
            viewModelGeneral.init();
        }

        kendo.bind( fields.boxPricing, model );

        fields.boxPricing.show();

    };

    pub.getData = function( itemId ) {

        var model = getCurrentViewModel();
        return model.get( "pricing" );

    };

    return pub;
} () );
