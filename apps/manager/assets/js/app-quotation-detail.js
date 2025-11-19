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
    $( ".k-listview-content" ).css( "display", "flex" );

    const signageModal = document.getElementById( "signage-modal" );
    signageModal.addEventListener( "hide.bs.modal", ( e ) => {
        AP.quotationDetail.detail.renderTotals();
    } );

    const plateModal = document.getElementById( "plate-modal-root" );
    plateModal.addEventListener( "hide.bs.modal", ( e ) => {
        AP.quotationDetail.detail.renderTotals();
    } );

    const accessoryModal = document.getElementById( "accessory-modal" );
    accessoryModal.addEventListener( "hide.bs.modal", ( e ) => {
        AP.quotationDetail.detail.renderTotals();
    } );

    $( "form#zone-form" ).on( "submit", function( e ) {
        e.preventDefault();
        AP.quotationDetail.zoneModal.methods().createZone();
        return false;
    } );
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
        mode: null,
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
        exportQuotation: function() {
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations-export/" + AP.page.quotation.id,
                callback: {
                    done: function( xhr ) {
                        if( xhr.status == "INVALID" ) {
                            NM.form.showMessages( xhr.data );
                            return;
                        }
                        AP.widget.notify( "success", "Preventivo Esportato correttamente." );
                    }
                }
            } );
        },
        printQuotation: function() {
            window.open(
                "/manager/technical-reports/print?id=" + AP.page.quotation.id,
                "_blank"
            );
        },
        changeMode: function( e ) {
            viewModel.set( "mode", e.currentTarget.textContent.toLowerCase() );
            viewModel.getItems();
        },
        getMode: function() {
            return viewModel.get( "mode" );
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
            // REF: non servono più ma lascio per sicurezza
            // event.stopPropagation();
            // event.preventDefault();

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
                                    if( xhr.status == "INVALID" ) {
                                        NM.form.showMessages( xhr.data );
                                        return;
                                    }
                                    // REF: fare il check su "SUCCESS" non occorre: te lo fa la libreria.
                                    // se è "ERROR" (500) viene mostrato un messaggio generico di errore.
                                    // if ( xhr.status == "SUCCESS" ) {
                                    AP.widget.notify( "success", "Riga di preventivo cancellata correttamente." );
                                    viewModel.set( "detailForm", defaultDetailForm );
                                    window.location.href = "/manager/quotations/" + AP.page.quotation.id;
                                    // }
                                }
                            }
                        } );
                    }
                },
            } );

            // REF: per evitare che il click sul link faccia anche il redirect
            return false;
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
                        // REF: ho tolto "preventivo" dappertutto
                        // siamo già nel dominio, abbiamo poco spazio ed è inutile ripeterlo
                        required: "Nome richiesto.",
                    },
                    number: {
                        required: "Numero richiesto."
                    },
                    langId: {
                        required: "Lingua richiesta."
                    },
                    validityDate: {
                        required: "Data validità richiesta."
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
                                if ( NM.storage.get( "quotation.zone.id" ) ) {
                                    var selectedZone = zones.find( zone => zone.id == NM.storage.get( "quotation.zone.id" ) );
                                    if ( !selectedZone ) {
                                        NM.storage.delete( "quotation.zone.id" );
                                        NM.storage.delete( "quotation.zone.name" );
                                        selectedZone = zones[0];
                                    }
                                    viewModel.set( "detailForm.data.zone", selectedZone );
                                } else {
                                    viewModel.set( "detailForm.data.zone", zones[0] );
                                }
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
            var quotationItemsMode = viewModel.get( "mode" );
            if ( viewModel.detailForm.data.zone?.name != "" ) {
                var url = "/manager/ajax/quotation-items?quotationId=" + AP.page.quotation.id + "&mode=" + quotationItemsMode;
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

            if ( viewModel.detailForm.data.zone && viewModel.detailForm.data.zone.id != "" ) {
                NM.storage.set( "quotation.zone.id", viewModel.detailForm.data.zone.id );
                NM.storage.set( "quotation.zone.name", viewModel.detailForm.data.zone.name );
                $( "#addSignageButton" ).prop( "disabled", false );
                $( "#addAccessoryButton" ).prop( "disabled", false );
            } else {
                NM.storage.delete( "quotation.zone.id" );
                NM.storage.delete( "quotation.zone.name" );
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

        addPlate: function() {
            plateApp().new();
        },

        editSignage: function( event ) {
            event.preventDefault();
            signageApp().edit( { id: event.data.id } );
            const tabellaTotali = $( "#totalsFloatingTab" ).find( "table" )[0];
            $( tabellaTotali ).empty();
        },

        editAccessory: function( event ) {
            event.preventDefault();
            accessoryApp().edit( { id: event.data.id } );
            const tabellaTotali = $( "#totalsFloatingTab" ).find( "table" )[0];
            $( tabellaTotali ).empty();
        },

        editPlate: function( event ) {
            event.preventDefault();
            signageApp().edit( { id: event.data.id } );
            const tabellaTotali = $( "#totalsFloatingTab" ).find( "table" )[0];
            $( tabellaTotali ).empty();
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
            this.renderTotals();
            viewModel.set( "detailForm.data", AP.page.quotation );
            if ( AP.page.quotation.customerAddressId && AP.page.quotation.customer.shippingAddresses ) {
                const shippingAddress = AP.page.quotation.customer.shippingAddresses.find( item => item.id === AP.page.quotation.customerAddressId );
                if ( shippingAddress ) {
                    viewModel.set( "detailForm.data.shippingAddress", shippingAddress );
                }
            }
            // $( "#nav-plan-tab" ).removeAttr("hidden");
            $( "#nav-products-tab" ).removeAttr( "hidden" );
            // $( "#nav-shipments-tab" ).removeAttr("hidden");
        }
    };

    // era: renderQuotationTotals()
    // REF: davantia lla funzione manca il "var" perchè avevi
    // la necessità che fosse pubblica
    // è sufficiente metterlo in "pub" per averlo in:
    // AP.quotationDetail.detail.renderQuotationTotals()
    // la prossima volta lo facciamo con mvvm

    pub.renderTotals = function() {
        /*
        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/" + AP.page.quotation.id + "/total",
            callback: {
                done: function( xhr ) {
                    if( xhr.data ) {
                        if ( !xhr.data.id || xhr.data.id != viewModel.get( "detailForm.data.id" ) ) {
                            $( "#totalsFloatingTab" ).hide();
                        } else {
                            viewModel.set( "detailForm.data.totals", xhr.data );
                            var totals = viewModel.get( "detailForm.data.totals" );
                            const table = $( "#totalsFloatingTab" ).find( "table" )[0];
                            $( table ).empty();
                            $( table ).append(
                                `<tr>
                                    <td>${totals.quantity.label}</td>
                                    <td>${totals.quantity.count}</td>
                                </tr>
                                <tr style="font-weight: bold">
                                    <td>${totals.total.label}</td>
                                    <td>${totals.total.amount.toLocaleString( "it-IT", { style: "currency", currency: "EUR" } )}</td>
                                </tr>
                                `
                            );
                            $( "#totalsFloatingTab" ).show();
                        }
                    }
                }
            }
        } );
        */
    };

    return pub;
} () );

AP.quotationDetail.zoneModal = ( function() {
    var pub = {};
    // REF: il nome è errato
    var fields = AP.quotationDetail.fields;

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
            // REF: è sufficiente configurarlo con jquery validator,
            // senza check manuali

            // const parsedData = viewModel.get( "detailForm.data" );
            // if ( parsedData.name.trim() == "" ) {
            //    AP.widget.notify( "error", "Specificare un nome per la zona." );
            //    return false;
            // }

            var zoneForm = $( "#zone-form" );

            if ( zoneForm.valid() ) {
                Loading.show()
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/quotations/zones",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "INVALID" ) {
                                Loading.show()
                                NM.form.showMessages( xhr.data );
                                return;
                            }

                            AP.widget.notify( "success", "Zona salvata correttamente." );
                            setTimeout( function () {
                                $( "#zone-modal-root" ).modal( "hide" )
                                Loading.hide()   
                            }, 200 );
                            AP.quotationDetail.detail.methods().getZones();
                        }
                    }
                } );

            }

            return false;
        },

        deleteZone: function( event ) {
            const zone = viewModel.get( "detailForm.data.parentZone" );

            var zoneForm = $( "#zone-form" );
            var status = zoneForm.find( ".status" );

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width=20 height=20>" );

            if ( zoneForm.valid() ) {
                Loading.show()
                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/quotations/zones",
                    data: JSON.stringify( { "zone": zone } ),
                    callback: {
                        done: function( xhr ) {

                            status.html( "" );

                            if ( xhr.status == "INVALID" ) {
                                NM.form.showMessages( xhr.data );
                                return;
                            }

                            AP.widget.notify( "success", xhr.data.message );
                            setTimeout( function () {
                                $( "#zone-modal-root" ).modal( "hide" )
                                Loading.hide()   
                            }, 200 );
                            AP.quotationDetail.detail.methods().getZones();

                        }
                    }
                } );
            }
            return false;
        },
    } );

    pub.init = function( mode ) {
        kendo.bind( fields.zoneModalRoot, viewModel );

        var zoneForm = $( "#zone-form" );

        NM.form.removeRules( zoneForm );

        if ( mode == "delete" ) {

            var zones = AP.quotationDetail.detail.config().get( "zones" ).filter( ( zone ) => { return zone.id != ""; } );

            zones.unshift( { "id": "", "name": "-- seleziona una zona" } );

            viewModel.get( "zones" ).data( zones );
            $( "#zoneTitle" ).text( "Elimina Zona" );

            $( "#delete-zone-button" ).show();
            $( "#add-zone-button" ).hide();
            $( "#zone-name-input" ).hide();
            $( "#zone-label-parent" ).html( "Zona" );

            // REF: aggiungo validazione per cancellazione
            zoneForm.validate( {
                onfocusout: function( element ) {
                    $( element ).valid();
                },
                rules: {
                    parentId: {
                        required: true
                    },
                },
                messages: {
                    parentId: {
                        required: "Seleziona una zona"
                    },
                },
            } );

        }

        if ( mode == "add" ) {

            var zones = AP.quotationDetail.detail.config().get( "zones" ).filter( ( zone ) => { return zone.id != "" && !zone.origin; } );

            zones.unshift( { "id": "", "name": "-- nessuna" } );
            viewModel.get( "zones" ).data( zones );
            $( "#zoneTitle" ).text( "Nuova Zona" );

            $( "#delete-zone-button" ).hide();
            $( "#add-zone-button" ).show();
            $( "#zone-name-input" ).show();
            $( "#zone-label-parent" ).html( "Zona padre" );

            // REF: aggiungo validazione per inserimento
            zoneForm.validate( {
                onfocusout: function( element ) {
                    $( element ).valid();
                },
                rules: {
                    name: {
                        required: true
                    },
                },
                messages: {
                    name: {
                        required: "Inserisci un nome"
                    },
                },
            } );

        }
    };

    pub.methods = function( options ) {
        return viewModel;
    };
    return pub;
} () );