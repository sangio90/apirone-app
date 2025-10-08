AP.namespace( "quotationDetail" );

Object.assign( AP.quotationDetail.fields, {
    detailRoot: $( "#quotation-detail-root" ),
    detailForm: $( "#quotation-header-form" ),
    zoneModalRoot: $( "#zone-modal-root" ),
} );

$( document ).ready( function() {
    if ( AP.quotationDetail.fields.detailRoot.length ) {
        AP.quotationDetail.detail.init();
    }
    $( ".k-listview-content" ).first().css( "display", "flex" );

    const signageModal = document.getElementById('signage-modal');
    signageModal.addEventListener('hide.bs.modal', (e) => {
        renderQuotationTotals()
    });

    const plateModal = document.getElementById('plate-modal');
    plateModal.addEventListener('hide.bs.modal', (e) => {
        renderQuotationTotals()
    });

    const accessoryModal = document.getElementById('accessory-modal');
    accessoryModal.addEventListener('hide.bs.modal', (e) => {
        renderQuotationTotals()
    });
} );

AP.quotationDetail.detail = ( function() {
    var pub = {};

    function signageApp() {
        return AP.signage.modal;
    }

    function plateApp() {
        return AP.plate.modal;
    }

    function accessoryApp() {
        return AP.accessory.modal;
    }

    var defaultDetailForm = {
        data: {
            id: "",
            name: "",
            customer: {
                "id":"",
                "name":""
            },
            shippingAddress: {
                "id": null,
                "name": ""
            },
            quotationNumber: "",
            versionNumber: 1,
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
            opportunity: {
                "id":"",
                "name":""
            },
            lead: {
                "id":"",
                "name":""
            },
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
            title: this.id ? "Modifica Preventivo" : "Nuovo Preventivo",
            totals: {
                "id": null
            }
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
        crmCustomers: new kendo.data.DataSource( {
            serverFiltering: true,
            transport: {
                read: {
                    url: "/manager/ajax/quotations/crmcustomers/",
                    data: {
                        str: function() {
                            return $( "#customer" ).val();
                        },
                    }
                }
            },
            schema: {
                data: function( xhr ) {
                    return xhr.data;
                }
            }
        } ),
        crmOpportunities: new kendo.data.DataSource( {
            serverFiltering: true,
            transport: {
                read: {
                    url: "/manager/ajax/quotations/crmopportunities/",
                    data: {
                        str: function() {
                            return $( "#opportunity" ).val();
                        },
                    }
                }
            },
            schema: {
                data: function( xhr ) {
                    return xhr.data;
                }
            }
        } ),
        crmLeads: new kendo.data.DataSource( {
            serverFiltering: true,
            transport: {
                read: {
                    url: "/manager/ajax/quotations/crmleads/",
                    data: {
                        str: function() {
                            return $( "#lead" ).val();
                        },
                    }
                }
            },
            schema: {
                data: function( xhr ) {
                    return xhr.data.map( item => ( {
                        ...item,
                        fullName: `${item.firstName} ${item.lastName}`
                    } ) );
                }
            }
        } ),
        list: function() {
            window.location.href = "/manager/quotations";
        },

        getImageSrc: function( event ) {

            const uri = event.image?.uri || "";

            if ( uri.toLowerCase().endsWith( ".svg" ) ) {
                return uri;
            }

            if ( uri != "" )  {
                var replaced = uri.replace( "_ori", "500" );
                return replaced;
            }

            return "/assets/main/img/img-not-found.png";
        },

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

        delete: function( event ) {
            event.stopPropagation();
            event.preventDefault();
            var id = event.currentTarget.dataset.id;

            bootbox.confirm( {
                title: "Conferma eliminazione",
                message: "Sei sicuro di voler cancellare questa riga del preventivo?",
                buttons: {
                    confirm: {
                        label: "Si, confermo",
                        className: "btn-primary",
                    },
                    cancel: {
                        label: "No, chiudi",
                        className: "btn-danger",
                    },
                },
                callback: function( result ) {
                    if ( result ) {
                        NM.util.ajax( {
                            method: "DELETE",
                            url: "/manager/ajax/quotation-items",
                            data: id,
                            callback: {
                                done: function( xhr ) {
                                    if( xhr.status == "ERRORE" ) {
                                        AP.widget.notify( "error", "Errore nella cancellazione della riga di preventivo." );
                                    }
                                    if ( xhr.status == "SUCCESS" ) {
                                        AP.widget.notify( "success", "Riga di preventivo cancellata correttamente." );
                                        viewModel.set( "detailForm", defaultDetailForm );
                                        window.location.href = "/manager/quotations/" + AP.page.quotation.id;
                                    }
                                }
                            }
                        } );
                    }
                },
            } );
        },

        save: function( event ) {
            var detailFormDom = AP.quotationDetail.fields.detailForm;

            detailFormDom.validate( {
                onfocusout: function( element ) {
                    $( element ).valid();
                },
                rules: {
                    name: {
                        required: true
                    },
                    number: {
                        required: true
                    },
                    langId: {
                        required: true
                    },
                    validityDate: {
                        required: true
                    },
                },
                messages: {
                    name: {
                        required: "Nome preventivo richiesto.",
                    },
                    number: {
                        required: "Numero preventivo richiesto."
                    },
                    langId: {
                        required: "Lingua preventivo richiesta."
                    },
                    validityDate: {
                        required: "Data validità preventivo richiesta."
                    },
                }
            } );

            if ( detailFormDom.valid() ) {
                const parsedData = viewModel.get( "detailForm.data" );

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/quotations",
                    data: JSON.stringify( parsedData ),
                    callback: {
                        done: function( xhr ) {
                            if( xhr.status == "ERRORE" ) {
                                var error = "Errore nel salvataggio del preventivo.";
                                if ( xhr.data.error ) {
                                    error = xhr.data.error;
                                }
                                AP.widget.notify( "error", error );
                            }
                            if ( xhr.status == "SUCCESS" ) {
                                AP.widget.notify( "success", "Preventivo salvato correttamente." );
                                viewModel.set( "detailForm", defaultDetailForm );
                                window.location.href = "/manager/quotations/" + xhr.data.payload.ID;
                            }
                        }
                    }
                } );
            }

            return false;
        },

        getZones: function( e ) {

            if ( AP.page.quotation?.id ) { // if edit mode

                NM.util.ajax( {
                    method: "GET",
                    url: "/manager/ajax/quotations/" + AP.page.quotation.id + "/zones",
                    callback: {
                        done: function( xhr ) {
                            if( xhr.status == "ERRORE" ) {
                                AP.widget.notify( "error", "Errore nel recupero delle zone." );
                            }
                            if ( xhr.status == "SUCCESS" ) {
                                if ( xhr.data.length ) {
                                    var zones = xhr.data;
                                    zones.unshift( { "id": "", "name": "Tutte le zone" } );
                                } else {
                                    var zones = [ { "id": "", "name": "Tutte le zone" } ];
                                }
                                zones.forEach( function( zone ) {
                                    if ( zone.origin ) {
                                        zone.name = "\u00A0\u00A0- " + zone.name;
                                    }
                                } );
                                viewModel.get( "zones" ).data( zones );
                                viewModel.set( "detailForm.data.zone", zones[0] );
                                viewModel.set( "detailForm.data.zones", zones );
                                viewModel.getItems();
                            }
                        }
                    }
                } );

            }

            return false;
        },

        getItems: function( e ) {
            if ( viewModel.detailForm.data.zone.name != "" ) {
                var url = "/manager/ajax/quotation-items?quotationId=" + AP.page.quotation.id;
                if ( viewModel.detailForm.data.zone ) {
                    url = url + "&quotationZoneId=" + viewModel.detailForm.data.zone.id;
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

            if ( viewModel.detailForm.data.zone.id != "" ) {
                $( "#addSignageButton" ).prop( "disabled", false );
                $( "#addAccessoryButton" ).prop( "disabled", false );
            } else {
                $( "#addSignageButton" ).prop( "disabled", true );
                $( "#addAccessoryButton" ).prop( "disabled", true );
            }

            return false;
        },

        setQuotation: function( quotation ) {
            viewModel.set( "detailForm.data", quotation );
        },

        addSignage: function() {
            signageApp().new();
        },

        addAccessory: function() {
            accessoryApp().new();
        },

        editSignate: function( event ) {
            event.preventDefault();
            signageApp().edit( { id: event.data.id } );
            let tabellaTotali = $('#angolo').find('table')[0];
            $(tabellaTotali).empty();
        },

        addPlate: function() {
            plateApp().new();
        },

        openAddZoneModal: function() {
            if ( AP.quotationDetail.fields.zoneModalRoot.length ) {
                AP.quotationDetail.zoneModal.methods().resetForm();
                AP.quotationDetail.zoneModal.init( "add" );
            }
            NM.util.openModal( AP.quotationDetail.fields.zoneModalRoot );
        },

        openDeleteZoneModal: function() {
            if ( AP.quotationDetail.fields.zoneModalRoot.length ) {
                AP.quotationDetail.zoneModal.init( "delete" );
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
        kendo.bind( AP.quotationDetail.fields.detailRoot, viewModel );

        viewModel.get( "languages" ).data( AP.page.languages );
        viewModel.get( "statuses" ).data( AP.page.statuses );
        viewModel.get( "pricelists" ).data( AP.page.pricelists );
        viewModel.get( "paymentMethods" ).data( AP.page.paymentMethods );
        viewModel.get( "currencies" ).data( AP.page.currencies );
        viewModel.get( "countries" ).data( AP.page.countries );
        viewModel.get( "states" ).data( AP.page.states );

        viewModel.getZones();

        if ( AP.page.quotation ) {
            if ( AP.page.quotation.lead && AP.page.quotation.lead.firstName && AP.page.quotation.lead.firstName != "" ) {
                AP.page.quotation.lead.fullName = AP.page.quotation.lead.firstName + " " + AP.page.quotation.lead.lastName;
            }
            renderQuotationTotals()
            viewModel.set( "detailForm.data", AP.page.quotation );
            if ( AP.page.quotation.customerAddressId && AP.page.quotation.customer.shippingAddresses ) {
                const shippingAddress = AP.page.quotation.customer.shippingAddresses.find(item => item.id === AP.page.quotation.customerAddressId);
                if (shippingAddress) {
                    viewModel.set('detailForm.data.shippingAddress', shippingAddress);
                }
            }
            // $( "#nav-plan-tab" ).removeAttr("hidden");
            $( "#nav-products-tab" ).removeAttr( "hidden" );
            // $( "#nav-shipments-tab" ).removeAttr("hidden");
        }
    };

    renderQuotationTotals = function() {
        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/" + AP.page.quotation.id + "/total",
            callback: {
                done: function( xhr ) {
                    if( xhr.data ) {
                        if (!xhr.data.id || xhr.data.id != viewModel.get('detailForm.data.id')) {
                            $('#angolo').hide();
                        } else {
                            viewModel.set('detailForm.data.totals', xhr.data)
                            var totals = viewModel.get('detailForm.data.totals');
                            let table = $('#angolo').find('table')[0]
                            $(table).empty()
                            $(table).append(
                                `<tr>
                                    <td>${totals.quantity.label}</td>
                                    <td>${totals.quantity.count}</td>
                                </tr>
                                <tr style="font-weight: bold">
                                    <td>${totals.total.label}</td>
                                    <td>${totals.total.amount.toLocaleString('it-IT', { style: 'currency', currency: 'EUR'})}</td>
                                </tr>
                                `
                            )
                            $('#angolo').show();
                        }
                    }
                }
            }
        } );
    }

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
                id: AP?.page?.quotation?.id || "00001", // TODO: better than this
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
            if ( parsedData.name.trim() == "" ) {
                AP.widget.notify( "error", "Specificare un nome per la zona." );
                return false;
            }

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
                data: JSON.stringify( { "zone": zone } ),
                callback: {
                    done: function( xhr ) {
                        if( xhr.status == "ERRORE" ) {
                            if ( xhr.data?.error ) {
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
            var zones = AP.quotationDetail.detail.config().get( "zones" ).filter( ( zone ) => { return zone.id != "" && !zone.origin; } );
            zones.unshift( { "id": "", "name": "" } );
            viewModel.get( "zones" ).data( zones );
            $( "#delete-zone-button" ).hide();
            $( "#add-zone-button" ).show();
            $( "#zone-name-input" ).show();
        }
    };

    pub.methods = function( options ) {
        return viewModel;
    };
    return pub;
} () );