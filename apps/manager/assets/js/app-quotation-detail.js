AP.namespace( "quotationDetail" );

Object.assign( AP.quotationDetail.fields, {
    detailRoot: $( "#quotation-detail-root" )
} );

$( document ).ready( function() {
    if ( AP.quotationDetail.fields.detailRoot.length ) {
        AP.quotationDetail.detail.init();
    }
} );

AP.quotationDetail.detail = ( function() {
    var pub = {};

    var plateApp   = AP.plate.designer;
    var signageApp = AP.signage.modal;
    // var zoneModal = AP.zone.modal;
    
    var defaultDetailForm = {
        data: {
            id: "",
            name: "",
            number: "",
            version: 1,
            language: {
                "id":""
            },
            zone: {
                "id":"",
                "name":""
            },
            quotationDate: new Date(),
            validityDate: new Date(),
            notes: "",
            status: {
                "id":""
            },
            opportunityName: "",
            leadName: "",
            pricelist: {
                "id":""
            },
            paymentMethod: {
                "id":""
            },
            customPaymentMethod: "",
            vatNumber: "",
            currency: {
                "id":""
            },
            invoiceData: {
                "name":"",
                "company":"",
                "vatNumber":"",
                "email":"",
                "phone":"",
                "street":"",
                "city":"",
                "postalCode":"",
                "country": {"id":""},
                "state": {"id":""}
            },
            shipmentData: {
                "name":"",
                "company":"",
                "vatNumber":"",
                "email":"",
                "phone":"",
                "street":"",
                "city":"",
                "postalCode":"",
                "country": {"id":"","name":""},
                "state": {"id":"","name":""}
            },
            title: this.id ? "Modifica Preventivo" : "Nuovo Preventivo"
        }
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,
        languages: new kendo.data.DataSource(),
        statuses: new kendo.data.DataSource(),
        pricelists: new kendo.data.DataSource(),
        paymentMethods: new kendo.data.DataSource(),
        currencies: new kendo.data.DataSource(),
        countries: new kendo.data.DataSource(),
        states: new kendo.data.DataSource(),
        filteredInvoiceStates: new kendo.data.DataSource(),
        filteredShipmentStates: new kendo.data.DataSource(),
        zones: new kendo.data.DataSource(),
        quotationItems: new kendo.data.DataSource(),

        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        loadInvoiceStates: function() {
            var country = this.detailForm.data.invoiceData.country;
            if ( country && country.id ) {
                this.filteredInvoiceStates.data( [] );
                var that = this;
                viewModel.states.fetch( function() {
                    var data = that.states.data().filter( function( item ) {
                        return item.countryId == country.id;
                    } );
                    that.filteredInvoiceStates.data( data );
                    if ( data.length == 1 ) {
                        that.detailForm.data.invoiceData.state = { id: data[0].id };
                    } else {
                        that.detailForm.data.invoiceData.state = { id: "" };
                    }
                } );
            } else {
                this.filteredInvoiceStates.data( [] );
                this.detailForm.data.invoiceData.state = { id: "" };
            }
        },

        loadShipmentStates: function() {
            var country = this.detailForm.data.shipmentData.country;
            if ( country && country.id ) {
                this.filteredShipmentStates.data( [] );
                var that = this;
                viewModel.states.fetch( function() {
                    var data = that.states.data().filter( function( item ) {
                        return item.countryId == country.id;
                    } );
                    that.filteredShipmentStates.data( data );
                    if ( data.length == 1 ) {
                        that.detailForm.data.shipmentData.state = { id: data[0].id };
                    } else {
                        that.detailForm.data.shipmentData.state = { id: "" };
                    }
                } );
            } else {
                this.filteredShipmentStates.data( [] );
                this.detailForm.data.shipmentData.state = { id: "" };
            }
        },

        resetForm: function() {},

        save: function( event ) {
            let parsedData = viewModel.get('detailForm.data');

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/quotations",
                data: JSON.stringify(parsedData),
                callback: {
                done: function( xhr ) {
                    if( xhr.status == "ERRORE" ) {
                        AP.widget.notify( "error", "Errore nel salvataggio del preventivo." );
                    } 
                    if ( xhr.status == "SUCCESS" ) {
                        AP.widget.notify( "success", "Preventivo salvato correttamente." );
                        viewModel.set( "detailForm", defaultDetailForm );
                        setTimeout( () => $( "#signage-modal" ).modal( "hide" ), 1000 );
                    }}
                }
            } );


            return false;
        },

        getZones: function( e ) {
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotationzones/" + AP.page.quotation.id,
                callback: {
                done: function( xhr ) {
                        if( xhr.status == "ERRORE" ) {
                            AP.widget.notify( "error", "Errore nel recupero delle zone." );
                        } 
                        if ( xhr.status == "SUCCESS" ) {
                            var zones = xhr.data.length ? xhr.data : [ { "id": "", "name": "Tutte le zone" } ];
                            zones.unshift( { "id": "", "name": "Tutte le zone" } );
                            viewModel.get('zones').data(zones);
                            viewModel.set('detailForm.data.zone', zones[0]);
                            viewModel.getItems();
                        }
                    }
                }
            } );


            return false;
        },
        
        getItems: function( e ) {
            if (viewModel.detailForm.data.zone.name != "") {
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/quotationitems",
                    data: JSON.stringify({ zoneId: viewModel.detailForm.data.zone ? viewModel.detailForm.data.zone.id : "", quotationId: AP.page.quotation.id }),
                    callback: {
                        done: function( xhr ) {
                            if( xhr.status == "ERRORE" ) {
                                AP.widget.notify( "error", "Errore nel recupero delle righe." );
                            } 
                            if ( xhr.status == "SUCCESS" ) {
                                viewModel.get('quotationItems').data(xhr.data);
                            }
                        }
                    }
                } );
            }
            
            return false;
        },

        addSignage: function() {
            signageApp.new();
        },

        addPlate: function() {
            plateApp.new();
        },

        // addZone: function() {
        //     zoneModal.new();
        // }
    } )

    pub.init = function() {
        viewModel.get( "languages" ).data( AP.page.languages )
        viewModel.get( "statuses" ).data( AP.page.statuses )
        viewModel.get( "pricelists" ).data( AP.page.pricelists )
        viewModel.get( "paymentMethods" ).data( AP.page.paymentMethods )
        viewModel.get( "currencies" ).data( AP.page.currencies )
        viewModel.get( "countries" ).data( AP.page.countries )
        viewModel.get( "states" ).data( AP.page.states )
        viewModel.getZones();

        if ( AP.page.quotation ) {
            // $( "#nav-plan-tab" ).removeAttr("hidden");
            $( "#nav-products-tab" ).removeAttr("hidden");
            // $( "#nav-shipments-tab" ).removeAttr("hidden");
        }
        kendo.bind( AP.quotationDetail.fields.detailRoot, viewModel );
    };
    
    return pub;
} () );