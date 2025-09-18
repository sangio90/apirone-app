AP.namespace( "quotationDetail" );

Object.assign( AP.quotationDetail.fields, {
    detailRoot: $( "#quotation-detail-root" ),
    zoneModalRoot: $( "#zone-modal-root" ),
} );

$( document ).ready( function() {
    if ( AP.quotationDetail.fields.detailRoot.length ) {
        AP.quotationDetail.detail.init();
    }
    $(".k-listview-content").first().css("display", "flex");
} );

AP.quotationDetail.detail = ( function() {
    var pub = {};

    function signageApp() {
        return AP.signage.modal;
    }

    function plateApp() {
        return AP.plate.modal;
    }

    var defaultDetailForm = {
        data: {
            id: "",
            name: "",
            quotationNumber: "",
            version: 1,
            lang: {
                "id":""
            },
            zone: {
                "id":"",
                "name":""
            },
            zones: new kendo.data.DataSource(), 
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
                "country": { "id":"" },
                "state": { "id":"" }
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
                "country": { "id":"", "name":"" },
                "state": { "id":"", "name":"" }
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
            const parsedData = viewModel.get( "detailForm.data" );

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/quotations",
                data: JSON.stringify( parsedData ),
                callback: {
                    done: function( xhr ) {
                        if( xhr.status == "ERRORE" ) {
                            AP.widget.notify( "error", "Errore nel salvataggio del preventivo." );
                        }
                        if ( xhr.status == "SUCCESS" ) {
                            AP.widget.notify( "success", "Preventivo salvato correttamente." );
                            viewModel.set( "detailForm", defaultDetailForm );
                            setTimeout( () => $( "#signage-modal" ).modal( "hide" ), 1000 );
                        }
                    }
                }
            } );

            return false;
        },

        getZones: function( e ) {
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/" + AP.page.quotation.id + "/zones",
                callback: {
                    done: function( xhr ) {
                        if( xhr.status == "ERRORE" ) {
                            AP.widget.notify( "error", "Errore nel recupero delle zone." );
                        }
                        if ( xhr.status == "SUCCESS" ) {
                            var zones = xhr.data.length ? xhr.data : [ { "id": "", "name": "Tutte le zone" } ];
                            zones.unshift( { "id": "", "name": "Tutte le zone" } );
                            zones.forEach(function(zone) {
                                if (zone.origin) {
                                    zone.name = "\u00A0\u00A0- " + zone.name;
                                }
                            });
                            viewModel.get( "zones" ).data( zones );
                            viewModel.set( "detailForm.data.zone", zones[0] );
                            viewModel.set( "detailForm.data.zones", zones );
                            viewModel.getItems();
                        }
                    }
                }
            } );


            return false;
        },

        getItems: function( e ) {
            if ( viewModel.detailForm.data.zone.name != "" ) {
                var url = '/manager/ajax/quotationitems?quotationId=' + AP.page.quotation.id;
                if (viewModel.detailForm.data.zone) {
                    url = url + '&quotationZoneId=' + viewModel.detailForm.data.zone.id
                }
                NM.util.ajax( {
                    method: "GET",
                    url: url,
                    callback: {
                        done: function( xhr ) {
                            if( xhr.status == "ERRORE" ) {
                                AP.widget.notify( "error", "Errore nel recupero delle righe." );
                            }
                            if ( xhr.status == "SUCCESS" ) {
                                viewModel.get( "quotationItems" ).data( xhr.data );
                            }
                        }
                    }
                } );
            }
            if (viewModel.detailForm.data.zone.id != '') {
                $('#addSignageButton').prop('disabled', false)
            } else {
                $('#addSignageButton').prop('disabled', true)
            }

            return false;
        },

        setQuotation: function( quotation ) {
            viewModel.set( "detailForm.data", quotation );
        },

        addSignage: function() {
            signageApp().new();
        },

        editSignate: function (event) {
            event.preventDefault();
            signageApp().edit({ id: event.data.id });
        },

        addPlate: function() {
            plateApp().new();
        },

        openAddZoneModal: function() {
            if ( AP.quotationDetail.fields.zoneModalRoot.length ) {
                AP.quotationDetail.zoneModal.init('add');
            }
            NM.util.openModal( AP.quotationDetail.fields.zoneModalRoot );
        },

        openDeleteZoneModal: function() {
            if ( AP.quotationDetail.fields.zoneModalRoot.length ) {
                AP.quotationDetail.zoneModal.init('delete');
            }
            NM.util.openModal( AP.quotationDetail.fields.zoneModalRoot );
        }
    } );

    pub.config = function( options ) {
        return viewModel.get( "detailForm.data" );
    };

    pub.methods = function( options ) {
        return viewModel;
    };

    pub.init = function() {
        viewModel.get( "languages" ).data( AP.page.languages );
        viewModel.get( "statuses" ).data( AP.page.statuses );
        viewModel.get( "pricelists" ).data( AP.page.pricelists );
        viewModel.get( "paymentMethods" ).data( AP.page.paymentMethods );
        viewModel.get( "currencies" ).data( AP.page.currencies );
        viewModel.get( "countries" ).data( AP.page.countries );
        viewModel.get( "states" ).data( AP.page.states );
        viewModel.getZones();
        viewModel.setQuotation( AP.page.quotation );
        if ( AP.page.quotation ) {
            // $( "#nav-plan-tab" ).removeAttr("hidden");
            $( "#nav-products-tab" ).removeAttr( "hidden" );
            // $( "#nav-shipments-tab" ).removeAttr("hidden");
        }
        kendo.bind( AP.quotationDetail.fields.detailRoot, viewModel );
    };

    return pub;
} () );

AP.quotationDetail.zoneModal = ( function() {
    var pub = {};
    var fields = AP.quotationDetail.fields.zoneModalRoot;
    var defaultDetailForm = {
        data: {
            id: "",
            name: "Nuova Zona",
            description: "",
            quotation: {
                id: AP.page.quotation.id
            },
            title: this.id ? "Modifica zona" : "Nuova zona",
            parentZone: {
                id: ""
            },
            mode: ""
        }
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,
        zones: new kendo.data.DataSource(),

        resetForm: function() {
            viewModel.set( "detailForm", defaultDetailForm );
        },

        createZone: function( event ) {
            const parsedData = viewModel.get( "detailForm.data" );

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/quotations/zones",
                data: JSON.stringify( parsedData ),
                callback: {
                    done: function( xhr ) {
                        if( xhr.status == "ERRORE" ) {
                            AP.widget.notify( "error", "Combinazione Zona già esistente in questo preventivo." );
                        } 
                        if ( xhr.status == "SUCCESS" ) {
                            AP.widget.notify( "success", "Zona salvata correttamente." );
                            setTimeout( () => $( "#zone-modal-root" ).modal( "hide" ), 1000 );
                            AP.quotationDetail.detail.methods().getZones();
                        }
                    }
                }
            } );
            return false;
        },

        deleteZone: function( event ) {
            const zone = viewModel.get( "detailForm.data.parentZone" );

            NM.util.ajax( {
                method: "DELETE",
                url: "/manager/ajax/quotations/zones",
                data: JSON.stringify({'zone': zone}),
                callback: {
                    done: function( xhr ) {
                        if( xhr.status == "ERRORE" ) {
                            if (xhr.data?.error) {
                                AP.widget.notify( "error", xhr.data.error );
                            } else {
                                AP.widget.notify( "error", "Errore durante la cancellazione di una zona." );
                            }
                        } 
                        if ( xhr.status == "SUCCESS" ) {
                            AP.widget.notify( "success", "Zona eliminata correttamente." );
                            setTimeout( () => $( "#zone-modal-root" ).modal( "hide" ), 1000 );
                            AP.quotationDetail.detail.methods().getZones();
                        }
                    }
                }
            } );
            return false;
        },
    } );

    pub.init = function( mode ) {
        kendo.bind( fields, viewModel );
        if ( mode == "delete" ) {
            viewModel.get( "zones" ).data( AP.quotationDetail.detail.config().get( "zones" ).filter( ( zone ) => { return zone.id != ""; } ) );
            $( "#delete-zone-button" ).show();
            $( "#add-zone-button" ).hide();
            $( "#zone-name-input" ).hide();
        }
        if ( mode == "add" ) {
            viewModel.get( "zones" ).data( AP.quotationDetail.detail.config().get( "zones" ).filter( ( zone ) => { return zone.id != "" && !zone.origin; } ) );
            $( "#delete-zone-button" ).hide();
            $( "#add-zone-button" ).show();
            $( "#zone-name-input" ).show();
        }
    };
    return pub;
} () );