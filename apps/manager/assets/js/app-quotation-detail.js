AP.namespace( "quotation" );

Object.assign( AP.quotation.fields, {
    detailRoot     : $( "#quotation-detail-root" ),
    detailForm     : $( "#quotation-detail-header-form" ),
    zoneModalRoot  : $( "#zone-modal-root" ),
    printModalRoot : $( "#print-modal-root" ),
    statusModalRoot: $( "#qt-status-modal-root" ),
    totalItemBox   : $( "#quotation-totals-item" ),

    addPlateBtn    : $( "#qt-add-plate" ),
    addSignageBtn  : $( "#qt-add-signage" ),
    addAccessoryBtn: $( "#qt-add-accessory" ),
    addArticleBtn  : $( "#qt-add-article" ),
} );

$( document ).ready( function() {
    if ( AP.quotation.fields.detailRoot.length ) {
        AP.quotation.detail.init();
    }

    [ "signage-modal", "plate-modal-root", "accessory-modal", "article-modal" ].forEach( id => {
        document.getElementById( id )?.addEventListener( "hide.bs.modal", () => {
            $('#quotation-total-pricing-box').show()
            AP.quotation.detail.showTotals();
            // Rimuove l'hash dall'URL quando si chiude la modale
            if ( window.location.hash ) {
                window.history.replaceState( null, null, window.location.pathname + window.location.search );
            }
        } );
        document.getElementById( id )?.addEventListener( "show.bs.modal", () => {
            $('#quotation-total-pricing-box').hide()
        });
    } );

    $( "form#zone-form" ).on( "submit", function( event ) {
        event.preventDefault();
        AP.quotation.zoneModal.methods().createZone();
        return false;
    } );
} );

AP.quotation.detail = ( function() {
    var pub = {};
    var fields = AP.quotation.fields;

    function signageApp() {
        return AP.signage.modal;
    }

    function plateApp() {
        return AP.plate.modal;
    }

    function accessoryApp() {
        return AP.accessory.modal;
    }

    function articleApp() {
        return AP.article.modal;
    }

    function headerApp() {
        return AP.quotation.header;
    }

    function statusApp() {
        return AP.quotation.status;
    }

    function pricingApp() {
        return AP.quotation.totalPricing;
    }

    var setQuotationItems = function( items ) {

        var typeId = viewModel.get( "typeId" );

        if ( typeId == "plate" ) {
            viewModel.set( "quotationItemsPlate", items );
        }

        if ( typeId == "signage" ) {
            viewModel.set( "quotationItemsSignage", items );
        }

        if ( typeId == "accessory" ) {
            viewModel.set( "quotationItemsAccessory", items );
        }

        if ( typeId == "article" ) {
            viewModel.set( "quotationItemsArticle", items );
        }

    };

    var getQuotationItems = function( items ) {

        var typeId = viewModel.get( "typeId" );

        if ( typeId == "plate" ) {
            return viewModel.get( "quotationItemsPlate" );
        }

        if ( typeId == "signage" ) {
            return viewModel.get( "quotationItemsSignage" );
        }

        if ( typeId == "accessory" ) {
            return viewModel.get( "quotationItemsAccessory" );
        }

        if ( typeId == "article" ) {
            return viewModel.get( "quotationItemsArticle" );
        }

    };


    var viewModel = kendo.observable( {
        typeId: "plate",
        showCosts: AP.getUserPref("showCosts"),
        detailForm: {
            data: {
                zone: {
                    id: ""
                },
            },
        },
        canEdit: AP.page.canEdit,
        canSee: AP.page.canSee,

        target: null,
        zones: new kendo.data.DataSource(),

        quotationItemsArticle: new kendo.data.DataSource( {} ),
        quotationItemsPlate: new kendo.data.DataSource( {} ),
        quotationItemsSignage: new kendo.data.DataSource( {} ),
        quotationItemsAccessory: new kendo.data.DataSource( {} ),

        showItems: function() {
            return getQuotationItems().total() > 0;
        },

        hideItems: function() {
            return getQuotationItems().total() == 0;
        },

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
            headerApp().edit( AP.page.quotation.id );
        },

        exportProducts: function() {
            AP.loading.show();
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations-export-products/" + AP.page.quotation.id,
                callback: {
                    done: function( xhr ) {
                        if( xhr.status == "INVALID" ) {
                            AP.loading.hide();
                            NM.form.showMessages( xhr.data );
                            return;
                        }

                        if ( xhr.data.error || xhr.data.success == false ) {
                            AP.widget.notify( "error", xhr.data.error ? xhr.data.error : "Errore durante l'esportazione del preventivo." );
                            AP.loading.hide();
                            return;
                        }

                        AP.loading.hide();

                        AP.widget.notify( "success", "Articoli esportati correttamente." );
                    }
                }
            } );
        },

        export: function() {
            AP.loading.show();
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations-export/" + AP.page.quotation.id,
                callback: {
                    done: function( xhr ) {
                        if( xhr.status == "INVALID" ) {
                            NM.form.showMessages( xhr.data );
                            return;
                        }

                        if ( xhr.data.error || xhr.data.success == false ) {
                            AP.widget.notify( "error", xhr.data.error ? xhr.data.error : "Errore durante l'esportazione del preventivo." );
                            AP.loading.hide();
                            return;
                        }

                        $( ".export-button" ).hide();
                        AP.widget.notify( "success", "Preventivo Esportato correttamente." );
                    },
                    always: function( xhr ) {
                        if ( xhr && xhr.data && (xhr.data.error || xhr.data.success == false) ) {
                            AP.widget.notify( "error", xhr.data.error ? xhr.data.error : "Errore durante l'esportazione del preventivo." );
                            AP.loading.hide();
                            return;
                        }
                        AP.loading.hide();
                    }
                }
            } );
        },

        changeType: function( event ) {

            var target = $( event.currentTarget );
            var type = target.data( "type" );

            viewModel.set( "typeId", type );
            viewModel.loadItems();

            // Aggiorna l'URL con il tab attivo
            var url = new URL( window.location );
            url.searchParams.set( "tab", type );
            window.history.pushState( {}, "", url );
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
            var itemId = event.currentTarget.dataset.id;

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
                            data: itemId,
                            callback: {
                                done: function( xhr ) {
                                    if ( xhr.status == "INVALID" ) {
                                        NM.form.showMessages( xhr.data );
                                        return;
                                    }

                                    AP.widget.notify( "success", "Riga cancellata correttamente." );
                                    window.location.href = "/manager/quotations/" + AP.page.quotation.id;
                                }
                            }
                        } );
                    }
                },
            } );

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

                            // almeno uno dei

                            var leadId = viewModel.get( "detailForm.data.lead.id" );
                            var customerId =  viewModel.get( "detailForm.data.customer.id" );
                            var opportunityId = viewModel.get( "detailForm.data.opportunity.id" );

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

                            AP.widget.notify( "success", "Preventivo salvato correttamente." );
                            viewModel.set( "detailForm", defaultDetailForm );
                            // window.location.href = "/manager/quotations/" + xhr.data.payload.ID;

                        }
                    }
                } );
            }

            return false;
        },

        getZones: async function( e ) {

            if ( AP.page.quotation?.id ) { // if edit mode

                await NM.util.ajax( {
                    method: "GET",
                    url: "/manager/ajax/quotations/" + AP.page.quotation.id + "/zones",
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.data.length ) {
                                var zones = xhr.data;
                            } else {
                                var zones = [];
                            }

                            zones.forEach( function( zone ) {
                                if ( zone.origin ) {
                                    zone.name = "\u00A0\u00A0- " + zone.name;
                                }
                            } );

                            viewModel.get( "zones" ).data( zones );

                            // la prima zona viene caricata con il preventivo

                            if ( NM.storage.get( "quotation.zone.id" ) ) {
                                var selectedZone = zones.find( zone => zone.id == NM.storage.get( "quotation.zone.id" ) );
                                if ( !selectedZone ) {
                                    NM.storage.delete( "quotation.zone.id" );
                                    NM.storage.delete( "quotation.zone.name" );
                                    selectedZone = zones[1];
                                }
                                viewModel.set( "detailForm.data.zone", selectedZone );
                            } else {
                                viewModel.set( "detailForm.data.zone", zones[0] );
                            }

                            viewModel.set( "detailForm.data.zones", zones );
                            viewModel.loadItems();
                        }
                    }
                } );

            }

            return false;
        },

        loadItems: function( e ) {
            var typeId = viewModel.get( "typeId" );

            var url = "/manager/ajax/quotations/" + AP.page.quotation.id + "/items/" + typeId;

            if ( viewModel.detailForm.data.zone && viewModel.detailForm.data.zone.id && viewModel.detailForm.data.zone.name != "-- Tutte le zone" ) {
                url = url + "?quotationZoneId=" + viewModel.detailForm.data.zone.id;
            }

            NM.util.ajax( {
                method: "GET",
                url: url,
                callback: {
                    done: function( xhr ) {
                        for (row in xhr.data) {
                            if (xhr.data[row].note) {
                                xhr.data[row].note_short = xhr.data[row].note.substr(0,23)
                            }
                        }
                        setQuotationItems( xhr.data );
                    }
                }
            } );

            if ( viewModel.detailForm.data.zone && viewModel.detailForm.data.zone.id != "" ) {
                AP.setUserPref( "quotation.zone.id", viewModel.detailForm.data.zone.id );
                AP.setUserPref( "quotation.zone.name", viewModel.detailForm.data.zone.name );
            } else {
                AP.deleteUserPref( "quotation.zone.id" );
                AP.deleteUserPref( "quotation.zone.name" );
            }

            return false;
        },

        setQuotation: function( quotation ) {
            viewModel.set( "detailForm.data", quotation );
        },

        // add

        addPlate: function() {
            plateApp().new();
            return false;
        },

        addSignage: function() {
            signageApp().new();
            return false;
        },

        addAccessory: function() {
            accessoryApp().new();
            return false;
        },

        addArticle: function() {
            articleApp().new();
            return false;
        },

        // edit

        edit: function( event ) {
            AP.loading.show();
            var typeId = viewModel.get( "typeId" );

            if ( typeId == "plate" ) {
                plateApp().edit( { id: event.data.id } );
            }

            if ( typeId == "accessory" ) {
                accessoryApp().edit( { id: event.data.id } );
            }

            if ( typeId == "signage" ) {
                signageApp().edit( { id: event.data.id } );
            }

            if ( typeId == "article" ) {
                articleApp().edit( event.data.id );
            }

            event.preventDefault();

        },

        clone: function( event ) {

            var typeId = viewModel.get( "typeId" );

            if ( typeId == "plate" ) {
                plateApp().clone( { id: event.data.id, clone: true  } );
            }

            if ( typeId == "accessory" ) {
                accessoryApp().clone( { id: event.data.id, clone: true  } );
            }

            if ( typeId == "signage" ) {
                signageApp().clone( { id: event.data.id, clone: true  } );
            }

            if ( typeId == "article" ) {
                articleApp().clone( { id: event.data.id, clone: true  } );
            }

            event.preventDefault();

        },

        /*
        editSignage: function( event ) {
            event.preventDefault();
            signageApp().edit( { id: event.data.id } );
            // AP.quotation.pricing.init( viewModel.get( "detailForm.data.id" ), "item" );
        },

        editAccessory: function( event ) {
            event.preventDefault();
            accessoryApp().edit( { id: event.data.id } );
            // AP.quotation.pricing.init( viewModel.get( "detailForm.data.id" ), "item" );
        },

        editPlate: function( event ) {
            event.preventDefault();
            // console.logx("editPlate")
            plateApp().edit( { id: event.data.id } );
            fields.totalItemBox.show();
            // AP.quotation.pricing.init( viewModel.get( "detailForm.data.id" ), "item", viewModel.get( "save" ) );
        },

        editArticle: function( event ) {
            event.preventDefault();
            articleApp().edit( { id: event.data.id } );
            fields.totalItemBox.show();
        },
        */

        clonePlate: function( event ) {
            event.preventDefault();
            event.stopPropagation();
            plateApp().edit( { id: event.data.id, clone: true } );
            fields.totalItemBox.show();
            // AP.quotation.pricing.init( viewModel.get( "detailForm.data.id" ), "item" );
        },

        openAddZoneModal: function() {
            if ( AP.quotation.fields.zoneModalRoot.length ) {
                AP.quotation.zoneModal.methods().resetForm();
                AP.quotation.zoneModal.init( "add" );
            }

            NM.util.openModal( AP.quotation.fields.zoneModalRoot );
        },

        openDuplicateZoneModal: function() {
            if ( AP.quotation.fields.zoneModalRoot.length ) {
                AP.quotation.zoneModal.methods().resetForm();
                AP.quotation.zoneModal.init( "duplicate" );
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

        openStatusModal: function() {

            statusApp().edit();

        },

        updateAllPrices: function() {
            AP.loading.show()
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/" + AP.page.quotation.id + "/updateallprices",
                callback: {
                    done: function( xhr ) {
                        AP.widget.notify('success', 'Prezzi articoli aggiornati con i costi fissi.')
                        setTimeout(() => {
                            window.location.reload()
                        }, 500)
                    }
                }
            } );
        }
    } );

    pub.showTotals = function( options ) {
        AP.quotation.totalPricing.init();
    };

    pub.checkUrlHash = function() {
        // Pattern: /manager/quotations/{quotationId}#$TYPE/{itemId}
        // Esempio: /manager/quotations/c7b80d01-6169-4050-b25a-8883d17c3126#plate/c7b80d01-6169-4050-b25a-8883d17c3126
        var hash = window.location.hash;

        if ( hash && hash.length > 1 ) {
            // Rimuove il # iniziale
            hash = hash.substring( 1 );

            // Divide per ottenere tipo e ID
            var parts = hash.split( "/" );

            if ( parts.length === 2 ) {
                var type = parts[0];
                var itemId = parts[1];

                // Chiama la funzione edit corrispondente
                switch ( type.toLowerCase() ) {
                case "plate":
                    if ( AP.plate && AP.plate.modal && AP.plate.modal.edit ) {
                        AP.plate.modal.edit( { id: itemId } );
                    }
                    break;
                case "signage":
                    if ( AP.signage && AP.signage.modal && AP.signage.modal.edit ) {
                        AP.signage.modal.edit( { id: itemId } );
                    }
                    break;
                case "accessory":
                    if ( AP.accessory && AP.accessory.modal && AP.accessory.modal.edit ) {
                        AP.accessory.modal.edit( { id: itemId } );
                    }
                    break;
                case "article":
                    if ( AP.article && AP.article.modal && AP.article.modal.edit ) {
                        AP.article.modal.edit( { id: itemId } );
                    }
                    break;
                default:
                    console.warn( "Unknown type in URL hash:", type );
                }
            }
        }
    };

    pub.checkUrlTab = function() {
        // Controlla il parametro ?tab= nell'URL e attiva il tab corrispondente
        var urlParams = new URLSearchParams( window.location.search );
        var tabParam = urlParams.get( "tab" );

        if ( tabParam ) {
            var validTabs = [ "plate", "signage", "accessory", "article" ];

            if ( validTabs.includes( tabParam.toLowerCase() ) ) {
                var tabType = tabParam.toLowerCase();
                var tabButton = document.querySelector( "button#nav-" + tabType + "-tab" );

                if ( tabButton ) {
                    // Rimuove la classe active da tutti i tab
                    document.querySelectorAll( ".nav-link" ).forEach( function( btn ) {
                        btn.classList.remove( "active" );
                    } );

                    // Nasconde tutti i tab-pane
                    document.querySelectorAll( ".tab-pane" ).forEach( function( pane ) {
                        pane.classList.remove( "show", "active" );
                    } );

                    // Attiva il tab corretto
                    tabButton.classList.add( "active" );
                    var targetPane = document.querySelector( tabButton.getAttribute( "data-bs-target" ) );
                    if ( targetPane ) {
                        targetPane.classList.add( "show", "active" );
                    }

                    // Aggiorna il viewModel
                    viewModel.set( "typeId", tabType );
                    viewModel.loadItems();

                    // Aggiorna la visibilità dei pulsanti
                    fields.addPlateBtn.toggle( tabType === "plate" );
                    fields.addSignageBtn.toggle( tabType === "signage" );
                    fields.addAccessoryBtn.toggle( tabType === "accessory" );
                    fields.addArticleBtn.toggle( tabType === "article" );
                }
            }
        }
    };

    pub.config = function( options ) {
        return viewModel.get( "detailForm.data" );
    };

    pub.methods = function( options ) {
        return viewModel;
    };

    pub.init = async function() {
        kendo.bind( AP.quotation.fields.detailRoot, viewModel );
        kendo.culture( "it-IT" );

        $('#quotation-totals-flat-discount-row').prop('hidden', !['ADM', 'CMA', 'TCD'].includes(AP.page.userRole.id));
        // Controlla se c'è un parametro tab nell'URL
        pub.checkUrlTab();

        // Se non c'è nessun tab nell'URL, carica il tab delle placche di default
        var urlParams = new URLSearchParams( window.location.search );

        if ( !urlParams.get( "tab" ) ) {
            $( "body" ).find( "button#nav-plate-tab" ).click();
            $('#qt-update-prices').show();
        } else {
            if (!['signage', 'plate'].includes(urlParams.get('tab'))) {
                $('#qt-update-prices').hide();
            }
        }

        try {
            await viewModel.getZones();

            const zones = viewModel.get( "detailForm.data.zones" );

            if (zones && zones.length > 0) {
                const defaultZone = zones.find( zone => zone.name == '-- Tutte le zone' );
                if (defaultZone) {
                    viewModel.set( "detailForm.data.zone", defaultZone || zones[0] );
                }
            }
        } catch (error) {
            console.error("Errore durante il recupero delle zone:", error);
        }

        AP.quotation.detail.showTotals();

        // Controlla URL hash per auto-aprire edit modal
        // console.log( "init:checkUrlHash" );
        pub.checkUrlHash();

        if ( AP.page.quotation ) {

            document.querySelector( "#nav-plate-tab" ).addEventListener( "click", function( event ) {
                event.preventDefault();
                fields.addPlateBtn.show();
                fields.addSignageBtn.hide();
                fields.addAccessoryBtn.hide();
                fields.addArticleBtn.hide();
                $('#qt-update-prices').show();
            } );

            document.querySelector( "#nav-signage-tab" ).addEventListener( "click", function( event ) {
                event.preventDefault();
                fields.addPlateBtn.hide();
                fields.addSignageBtn.show();
                fields.addAccessoryBtn.hide();
                fields.addArticleBtn.hide();
                $('#qt-update-prices').show();
            } );

            document.querySelector( "#nav-accessory-tab" ).addEventListener( "click", function( event ) {
                event.preventDefault();
                fields.addPlateBtn.hide();
                fields.addSignageBtn.hide();
                fields.addAccessoryBtn.show();
                fields.addArticleBtn.hide();
                $('#qt-update-prices').hide();
            } );

            document.querySelector( "#nav-article-tab" ).addEventListener( "click", function( event ) {
                event.preventDefault();
                fields.addPlateBtn.hide();
                fields.addSignageBtn.hide();
                fields.addAccessoryBtn.hide();
                fields.addArticleBtn.show();
                $('#qt-update-prices').hide();
            } );

            pricingApp().getTotals();

        }

        $(document).on("click", "#toggle-costs-link", function () {
            viewModel.set("showCosts", AP.getUserPref("showCosts"));
        });
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
            name: "Nuova zona",
            quantity: 1,
            description: "",
            quotation: {
                id: AP?.page?.quotation?.id || "00001",
            },
            title: this.id ? "Modifica zona" : "Nuova zona",
            parentZone: {
                id: ""
            },
            mode: "",
            duplicaConSottozone: false,
        }
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,
        zones: new kendo.data.DataSource(),

        resetForm: function() {
            viewModel.set( "detailForm", defaultDetailForm );
        },

        createZone: function( event ) {

            var zoneForm = $( "#zone-form" );

            if ( zoneForm.valid() ) {
                AP.loading.show();
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/quotations/zones",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "INVALID" ) {
                                AP.loading.show();
                                NM.form.showMessages( xhr.data );
                                return;
                            }

                            AP.widget.notify( "success", "Zona salvata correttamente." );
                            setTimeout( function() {
                                $( "#zone-modal-root" ).modal( "hide" );
                                AP.loading.hide();
                            }, 200 );
                            AP.quotation.detail.methods().getZones();
                        }
                    }
                } );

            }

            return false;
        },

        duplicateZone: function( event ) {
            const duplicaConSottozone = event.currentTarget.id == 'duplicate-zone-with-children-button'
            viewModel.set('detailForm.data.duplicaConSottozone', duplicaConSottozone)

            var zoneForm = $( "#zone-form" );

            if ( zoneForm.valid() ) {
                AP.loading.show();
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/quotations/duplicatezone",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "INVALID" ) {
                                AP.loading.hide();
                                NM.form.showMessages( xhr.data );
                                return;
                            }

                            AP.widget.notify( "success", "Zona salvata correttamente." );
                            setTimeout( function() {
                                $( "#zone-modal-root" ).modal( "hide" );
                                AP.loading.hide();
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
                AP.loading.show();
                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/quotations/zones",
                    data: JSON.stringify( { "zone": zone } ),
                    callback: {
                        done: function( xhr ) {

                            status.html( "" );

                            if ( xhr.status == "INVALID" ) {
                                NM.form.showMessages( xhr.data );
                                AP.loading.hide();
                                return;
                            }

                            AP.widget.notify( "success", xhr.data.message );
                            setTimeout( function() {
                                $( "#zone-modal-root" ).modal( "hide" );
                                AP.loading.hide();
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

            var zones = AP.quotation.detail.config().get( "zones" ).filter( function( zone ) { return zone.name != '-- Tutte le zone'; } );

            viewModel.get( "zones" ).data( zones );
            $( "#zoneTitle" ).text( "Elimina Zona" );

            $( "#delete-zone-button" ).show();
            $( "#duplicate-zone-button" ).hide();
            $( "#duplicate-zone-with-children-button" ).hide();
            $( "#add-zone-button" ).hide();
            $( "#zone-name-input" ).hide();
            $( "#zone-quantity-input" ).hide();
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

        if ( mode == "duplicate" ) {

            var zones = AP.quotation.detail.config().get( "zones" ).filter( ( zone ) => { return zone.name != '-- Tutte le zone'; } );

            viewModel.get( "zones" ).data( zones );
            $( "#zoneTitle" ).text( "Nuova Zona" );

            $( "#delete-zone-button" ).hide();
            $( "#add-zone-button" ).hide();
            $( "#duplicate-zone-button" ).show();
            $( "#duplicate-zone-with-children-button" ).show();
            $( "#zone-quantity-input" ).show();
            $( "#zone-name-input" ).show();
            $( "#zone-label-parent" ).html( "Zona da duplicare" );

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

        if ( mode == "add" ) {

            var zones = AP.quotation.detail.config().get( "zones" ).filter( ( zone ) => { return !zone.origin && zone.name != '-- Tutte le zone'; } );

            viewModel.get( "zones" ).data( zones );
            $( "#zoneTitle" ).text( "Nuova Zona" );

            $( "#delete-zone-button" ).hide();
            $( "#duplicate-zone-button" ).hide();
            $( "#duplicate-zone-with-children-button" ).hide();
            $( "#add-zone-button" ).show();
            $( "#zone-name-input" ).show();
            $( "#zone-quantity-input" ).show();
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
                    "id": "photo",
                    "name": "Foto"
                },
                {
                    "id": "zone",
                    "name": "Zone"
                },
                {
                    "id": "technical",
                    "name": "Tecnica"
                }
            ]
        }
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,

        print: function() {
            const report = viewModel.get( "detailForm.data.report.id" );
            const images = $( "#qt-print-image-checkbox" )[0].checked;
            const grouped = $( "#qt-print-grouped-checkbox" )[0].checked;
            const note = $( "#qt-print-note-checkbox" )[0].checked;
            const discounts = $( "#qt-print-discounts-checkbox" )[0].checked;

            const url = `/manager/technical-reports/print?id=${AP.page.quotation.id}&report=${report}` +
                `&images=${images}&grouped=${grouped}&note=${note}&discounts=${discounts}`;

            window.open( url, "_blank" );
        },

        toggleOptions: function() {
            const report = viewModel.get( "detailForm.data.report.id" );

            const imageCheckbox = $( "#qt-print-image-checkbox" );
            const groupedCheckbox = $( "#qt-print-grouped-checkbox" );
            const noteCheckbox = $( "#qt-print-note-checkbox" );
            const discountsCheckbox = $( "#qt-print-discounts-checkbox" );

            const imagesDiv = $( "#qt-print-images-cont" );
            const groupedDiv = $( "#qt-print-grouped-cont" );
            const noteDiv = $( "#qt-print-note-cont" );
            const discountsDiv = $( "#qt-print-discounts-cont" );

            // Reset tutto
            imageCheckbox.checked = false;
            groupedCheckbox.checked = false;
            noteCheckbox.checked = false;
            discountsCheckbox.checked = false;

            // Configurazione per ogni tipo di report
            const config = {
                classic: {
                    checkboxes: { image: true, grouped: false, note: false, discounts: false },
                    divs: { images: "block", grouped: "none", note: "block", discounts: "block" }
                },
                photo: {
                    checkboxes: { image: false, grouped: false, note: false, discounts: false },
                    divs: { images: "none", grouped: "block", note: "none", discounts: "none" }
                },
                zone: {
                    checkboxes: { image: true, grouped: false, note: true, discounts: false },
                    divs: { images: "block", grouped: "none", note: "block", discounts: "block" }
                },
                technical: {
                    checkboxes: { image: false, grouped: false, note: false, discounts: false },
                    divs: { images: "block", grouped: "block", note: "block", discounts: "none" }
                }
            };

            const reportConfig = config[report];

            if ( reportConfig ) {
                imageCheckbox.checked = reportConfig.checkboxes.image;
                groupedCheckbox.checked = reportConfig.checkboxes.grouped;
                noteCheckbox.checked = reportConfig.checkboxes.note;
                discountsCheckbox.checked = reportConfig.checkboxes.discounts;

                imagesDiv.css( "display", reportConfig.divs.images );
                groupedDiv.css( "display", reportConfig.divs.grouped );
                noteDiv.css( "display", reportConfig.divs.note );
                discountsDiv.css( "display", reportConfig.divs.discounts );
            }
        },

        resetForm: function() {
            viewModel.set( "detailForm", defaultDetailForm );
        }
    } );

    pub.init = function() {
        kendo.bind( fields.printModalRoot, viewModel );
        viewModel.toggleOptions();
    };

    pub.methods = function( options ) {
        return viewModel;
    };

    return pub;
} () );