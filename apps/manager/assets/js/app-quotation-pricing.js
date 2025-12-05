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

        return kendo.observable( {
            title: "",
            isCollapsed: false,
            symbol: "▼"
        } );

    };

    var collapseBox = function() {

        var model = getCurrentViewModel();
        var status = model.get( "common.isCollapsed" );

        model.set( "common.isCollapsed", !status );

        var newSymbol = !status ? "▲" : "▼";
        model.set( "common.symbol", newSymbol );

        return false;

    };

    var loadGeneral = function() {

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/" + AP.page.quotation.id + "/totals",
            callback: {
                done: function( xhr ) {

                    console.log( "xhr.data", xhr.data );

                }
            }
        } );

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

        update: function( event ) {

            var status = $( "#quotation-totals-item-loading" );
            status.html( "<img src='/assets/main/img/ajax-loading-blu.svg' width='20' height='20'>" );

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

        isItem: false,
        isGeneral: true,

        init: function( event ) {

            console.log( "viewModelGeneral:init. Load data..." );

            loadGeneral();

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

        update: function( event ) {

            var status = $( "#quotation-totals-item-loading" );
            status.html( "<img src='/assets/main/img/ajax-loading-blu.svg' width='20' height='20'>" );

            var data = AP.plate.modal.getVM().detailForm;
            data.data.pricing = viewModelGeneral.get( "pricing.data" );

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/quotation-items/pricing",
                data: JSON.stringify( data.data ),
                callback: {
                    done: function( xhr ) {
                        if ( xhr.data ) {

                            status.html( "" );

                            viewModelGeneral.set( "pricing.data", xhr.data );
                        }
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
            viewModelItem.set( "common.title", "Totali di questa riga" );
        } else {
            var model = viewModelGeneral;
            viewModelGeneral.set( "common.title", "Totali preventivo" );
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
