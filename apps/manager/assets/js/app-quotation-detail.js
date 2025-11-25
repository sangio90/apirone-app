AP.namespace( "quotation" );

Object.assign( AP.quotation.fields, {
    detailRoot: $( "#quotation-detail-root" ),
    detailForm: $( "#quotation-detail-header-form" ),
    zoneModalRoot: $( "#zone-modal-root" ),
    printModalRoot: $( "#print-modal-root" ),
} );

$( document ).ready( function() {
    if ( AP.quotation.fields.detailRoot.length ) {
        AP.quotation.detail.init();
    }

    const signageModal = document.getElementById( "signage-modal" );

    signageModal.addEventListener( "hide.bs.modal", ( e ) => {
        AP.quotation.detail.renderTotals();
    } );

    const plateModal = document.getElementById( "plate-modal-root" );
    plateModal.addEventListener( "hide.bs.modal", ( e ) => {
        AP.quotation.detail.renderTotals();
    } );

    const accessoryModal = document.getElementById( "accessory-modal" );
    accessoryModal.addEventListener( "hide.bs.modal", ( e ) => {
        AP.quotation.detail.renderTotals();
    } );

    $( "form#zone-form" ).on( "submit", function( e ) {
        e.preventDefault();
        AP.quotation.zoneModal.methods().createZone();
        return false;
    } );
} );

AP.quotation.detail = ( function() {
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

    function headerApp() {
        return AP.accessory.header;
    }

    var viewModel = kendo.observable( {
        detailForm: {
            data: {
                zone: {
                    id: ""
                }
            }
        },
        mode: null,
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

        showHeader: function() {
            NM.util.openModal( $( "#quotation-header-modal" ) );
        },

        exportQuotation: function() {
            Loading.show();
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations-export/" + AP.page.quotation.id,
                callback: {
                    done: function( xhr ) {
                        if( xhr.status == "INVALID" ) {
                            Loading.hide();
                            NM.form.showMessages( xhr.data );
                            return;
                        }
                        Loading.hide();
                        AP.widget.notify( "success", "Preventivo Esportato correttamente." );
                    }
                }
            } );
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
                                    AP.widget.notify( "success", "Riga di preventivo cancellata correttamente." );
                                    viewModel.set( "detailForm", defaultDetailForm );
                                    window.location.href = "/manager/quotations/" + AP.page.quotation.id;
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
            var detailFormDom = AP.quotation.fields.detailForm;

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
                    requireAnyOfCustomerLeadOrOpportunity: {
                        required: function() {

                            var leadId = viewModel.get( "detailForm.data.lead.id" );
                            var customerId =  viewModel.get( "detailForm.data.customer.id" );
                            var opportunityId = viewModel.get( "detailForm.data.opportunity.id" );

                            console.log( "leadId", leadId );
                            console.log( "customerId", customerId );
                            console.log( "opportunityId", opportunityId );

                            if ( customerId || leadId || opportunityId ) {
                                return false;
                            }

                            return true;
                        }
                    },
                },
                messages: {
                    name: {
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

                    requireAnyOfCustomerLeadOrOpportunity: {
                        required: "Compilare almeno un campo fra cliente, lead o opportunità"
                    }

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
            if ( quotationItemsMode == null ) {
                quotationItemsMode = $( "#quotationItemsMode" ).find( ".active" )[0].innerHTML.toLowerCase();
            }
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
            const tabellaTotali = $( "#quotation-totals-item" ).find( "table" )[0];
            $( tabellaTotali ).empty();
        },

        editAccessory: function( event ) {
            event.preventDefault();
            accessoryApp().edit( { id: event.data.id } );
            const tabellaTotali = $( "#quotation-totals-item" ).find( "table" )[0];
            $( tabellaTotali ).empty();
        },

        editPlate: function( event ) {
            event.preventDefault();
            signageApp().edit( { id: event.data.id } );
            const tabellaTotali = $( "#quotation-totals-item" ).find( "table" )[0];
            $( tabellaTotali ).empty();
        },


        openAddZoneModal: function() {
            if ( AP.quotation.fields.zoneModalRoot.length ) {
                AP.quotation.zoneModal.methods().resetForm();
                AP.quotation.zoneModal.init( "add" );
            }
            NM.util.openModal( AP.quotation.fields.zoneModalRoot );
        },

        openDeleteZoneModal: function() {
            if ( AP.quotation.fields.zoneModalRoot.length ) {
                AP.quotation.zoneModal.init( "delete" );
            }
            NM.util.openModal( AP.quotation.fields.zoneModalRoot );
        },

        openPrintModal: function() {
            if ( AP.quotation.fields.printModalRoot.length ) {
                AP.quotation.printModal.methods().resetForm();
                AP.quotation.printModal.init();
            }
            NM.util.openModal( AP.quotation.fields.printModalRoot );
        },
    } );

    pub.config = function( options ) {
        return viewModel.get( "detailForm.data" );
    };

    pub.methods = function( options ) {
        return viewModel;
    };

    pub.init = function() {
        kendo.bind( AP.quotation.fields.detailRoot, viewModel );

        viewModel.getZones();

        if ( AP.page.quotation ) {

            document.querySelector( "#nav-plate-tab" ).addEventListener( "click", function( e ) {
                e.preventDefault();
                $( "#addSignageButton" ).hide();
                $( "#addAccessoryButton" ).hide();
                $( "#addPlateButton" ).show();
            } );

            document.querySelector( "#nav-signage-tab" ).addEventListener( "click", function( e ) {
                e.preventDefault();
                $( "#addPlateButton" ).hide();
                $( "#addAccessoryButton" ).hide();
                $( "#addSignageButton" ).show();
            } );

            document.querySelector( "#nav-accessories-tab" ).addEventListener( "click", function( e ) {
                e.preventDefault();
                $( "#addPlateButton" ).hide();
                $( "#addSignageButton" ).hide();
                $( "#addAccessoryButton" ).show();
            } );

        }
    };

    pub.renderTotals = function() {
    };

    return pub;
} () );

AP.quotation.zoneModal = ( function() {
    var pub = {};
    // REF: il nome è errato
    var fields = AP.quotation.fields;

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
                Loading.show();
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/quotations/zones",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "INVALID" ) {
                                Loading.show();
                                NM.form.showMessages( xhr.data );
                                return;
                            }

                            AP.widget.notify( "success", "Zona salvata correttamente." );
                            setTimeout( function() {
                                $( "#zone-modal-root" ).modal( "hide" );
                                Loading.hide();
                            }, 200 );
                            AP.quotation.detail.methods().getZones();
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
                Loading.show();
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
                            setTimeout( function() {
                                $( "#zone-modal-root" ).modal( "hide" );
                                Loading.hide();
                            }, 200 );
                            AP.quotation.detail.methods().getZones();

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

            var zones = AP.quotation.detail.config().get( "zones" ).filter( ( zone ) => { return zone.id != ""; } );

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

            var zones = AP.quotation.detail.config().get( "zones" ).filter( ( zone ) => { return zone.id != "" && !zone.origin; } );

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

AP.quotation.printModal = ( function() {
    var pub = {};
    // REF: il nome è errato
    var fields = AP.quotation.fields;

    var defaultDetailForm = {
        data: {
            id: "",
            report: {
                "id": "classic",
                "name": "Classica"
            },
            reports: [
                {
                    "id": "classic",
                    "name": "Classica"
                },
                {
                    "id": "proforma",
                    "name": "Proforma"
                },
                {
                    "id": "zone",
                    "name": "Zone"
                },
                {
                    "id": "technical",
                    "name": "Tecnica"
                },
                {
                    "id": "internal",
                    "name": "Interna"
                }
            ]
        }
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,

        printQuotation: function() {
            const report = viewModel.get( "detailForm.data.report.id" );
            let url = "/manager/technical-reports/print?id=" + AP.page.quotation.id + "&report=" + report;
            const images = $( "#imagesCheckbox" )[0].checked;
            const grouped = $( "#groupedCheckbox" )[0].checked;
            const notes = $( "#notesCheckbox" )[0].checked;
            const discounts = $( "#discountsCheckbox" )[0].checked;
            if ( images ) { url += "&images=true"; } else { url += "&images=false"; }
            if ( grouped ) { url += "&grouped=true"; } else { url += "&grouped=false"; }
            if ( notes ) { url += "&notes=true"; } else { url += "&notes=false"; }
            if ( discounts ) { url += "&discounts=true"; } else { url += "&discounts=false"; }

            window.open( url, "_blank" );
        },

        toggleOptions: function() {
            const report = viewModel.get( "detailForm.data.report.id" );
            $( "#imagesCheckbox" )[0].checked = false;
            $( "#groupedCheckbox" )[0].checked = false;
            $( "#notesCheckbox" )[0].checked = false;
            $( "#discountsCheckbox" )[0].checked = false;
            if ( report == "classic" ) {
                $( "#imagesDiv" ).css( "display", "block" );
                $( "#groupedDiv" ).css( "display", "block" );
                $( "#notesDiv" ).css( "display", "block" );
                $( "#discountsDiv" ).css( "display", "block" );
            }
            if ( report == "proforma" ) {
                $( "#imagesDiv" ).css( "display", "none" );
                $( "#groupedDiv" ).css( "display", "block" );
                $( "#notesDiv" ).css( "display", "block" );
                $( "#discountsDiv" ).css( "display", "block" );
            }
            if ( report == "zone" ) {
                $( "#imagesDiv" ).css( "display", "none" );
                $( "#groupedDiv" ).css( "display", "block" );
                $( "#notesDiv" ).css( "display", "block" );
                $( "#notesCheckbox" )[0].checked = true;
                $( "#discountsDiv" ).css( "display", "block" );
            }
            if ( report == "technical" ) {
                $( "#imagesDiv" ).css( "display", "block" );
                $( "#groupedDiv" ).css( "display", "block" );
                $( "#notesDiv" ).css( "display", "block" );
                $( "#discountsDiv" ).css( "display", "none" );
            }
            if ( report == "internal" ) {
                $( "#imagesDiv" ).css( "display", "none" );
                $( "#groupedDiv" ).css( "display", "none" );
                $( "#notesDiv" ).css( "display", "none" );
                $( "#discountsDiv" ).css( "display", "none" );
            }
        },

        resetForm: function() {
            viewModel.set( "detailForm", defaultDetailForm );
        }
    } );

    pub.init = function() {
        kendo.bind( fields.printModalRoot, viewModel );
    };

    pub.methods = function( options ) {
        return viewModel;
    };
    return pub;
} () );