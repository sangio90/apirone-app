AP.namespace( "quotation" );

Object.assign( AP.quotation.fields, {
    headerRoot: $( "#quotation-header-root" ),
    haderForm: $( "#quotation-header-form" ),
} );

$( document ).ready( function() {
    if ( AP.quotation.fields.headerRoot.length ) {
        AP.quotation.header.init();
    }

} );

var quotationDate = new Date();
var validityDate = new Date( quotationDate );

validityDate.setMonth( validityDate.getMonth() + 1 );

AP.quotation.header = ( function() {
    var pub = {};
    var fields = AP.quotation.fields;

    var defaultDetailForm = {
        data: {
            id: "",
            name: "",
            customer: {
                id: "",
                name: ""
            },
            shippingProfile: {
                id: "",
                name: ""
            },
            quotationNumber: "",
            versionNumber: 1,
            lang: {
                id: "IT",
                name: ""
            },
            zone: {
                id: "",
                name: ""
            },
            quotationDate: quotationDate,
            validityDate: validityDate,
            note: "",
            statusFile: {
                id: null,
                file: null
            },
            opportunity: {
                id: "",
                name: ""
            },
            lead: {
                id: "",
                name: ""
            },
            pricelist: {
                id: ""
            },
            paymentMethod: {
                id: 18 // BB 60 GG FM
            },
            customPaymentMethod: "",
            currency: {
                id: 1
            },
            vatCode: {
                id: 22
            },
            graphicTechnician: {
                id: "",
                name: ""
            },
            salesAgent: {
                id: "",
                name: ""
            },
            invoiceData: {
                name: "",
                company: "",
                vatNumber: "",
                email: "",
                phone: "",
                street: "",
                city: "",
                postalCode: "",
                country: { id: "" },
                state: { id: "" }
            },
            shipmentData: {
                name: "",
                company: "",
                vatNumber: "",
                email: "",
                phone: "",
                street: "",
                city: "",
                postalCode: "",
                country: { id: "", name: "" },
                state: { id: "", name: "" }
            },
			nessunAgente: true,
			agente1: null,
			agente2: null,
			agente3: null,
			agente4: null,
			agente5: null,
			commission1: null,
			commission2: null,
			commission3: null,
			commission4: null,
			commission5: null,
			referenteAmministrativo: "",
			referenteSpedizione: "",
        },
        title: "Modifica preventivo",
        totals: {
            "id": null
        },
		agentiList: []
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,
        languages: new kendo.data.DataSource(),
        // varCodes: new kendo.data.DataSource(),
        statuses: new kendo.data.DataSource(),
        vatCodes: new kendo.data.DataSource(),
        pricelists: new kendo.data.DataSource(),
        paymentMethods: new kendo.data.DataSource(),
        currencies: new kendo.data.DataSource(),
        countries: new kendo.data.DataSource(),
        states: new kendo.data.DataSource(),
        quotationItems: new kendo.data.DataSource(),
        saleUsers: new kendo.data.DataSource(),
        techUsers: new kendo.data.DataSource(),
        canEdit: AP.page.canEdit,
        canSee: AP.page.canSee,
        agente2Enabled: false,
        agente3Enabled: false,
        agente4Enabled: false,
        agente5Enabled: false,

        crmCustomers: new kendo.data.DataSource( {
            serverFiltering: true,
            transport: {
                read: {
                    url: "/manager/ajax/quotations/crmcustomers",
                    data: {
                        str: function() {
                            return $( "#qt-customer" ).val();
                        },
                    }
                },
                parameterMap: function( data, type ) {
                    if ( type === "read" ) {
                        return { "str": data.str() };
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
                    url: "/manager/ajax/quotations/crmopportunities",
                    data: {
                        str: function() {
                            return $( "#qt-opportunity" ).val();
                        },
                    }
                },
                parameterMap: function( data, type ) {
                    if ( type === "read" ) {
                        return { "str": data.str() };
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
                    url: "/manager/ajax/quotations/crmleads",
                    data: {
                        str: function() {
                            return $( "#qt-lead" ).val();
                        },
                    }
                },
                parameterMap: function( data, type ) {
                    if ( type === "read" ) {
                        return { "str": data.str() };
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
            AP.loading.show();
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations-export/" + AP.page.quotation.id,
                callback: {
                    done: function( xhr ) {
                        if( xhr.status == "INVALID" ) {
                            AP.loading.hide();
                            NM.form.showMessages( xhr.data );
                            return;
                        }
                        AP.loading.hide();
                        AP.widget.notify( "success", "Preventivo esportato correttamente." );
                    }
                }
            } );
        },
		showAgenti: function() {
			return !viewModel.get("detailForm.data.nessunAgente");
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

        save: function() {

            var thisForm = fields.haderForm;
            var status = thisForm.find( ".save-status" );

            thisForm.validate( {
                onfocusout: function( element ) {
                    $( element ).valid();
                },
                rules: {
                    name: {
                        required: true
                    },
                    quotationNumber: {
                        required: true
                    },
                    lang: {
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

                            if ( customerId || leadId || opportunityId ) {
                                return false;
                            }

                            return true;
                        }
                    },
                    status: {
                        required: function() {

                            var statusId = viewModel.get( "detailForm.data.status.id" );
                            var statusFile = viewModel.get( "detailForm.data.statusFile" );
                            if ( statusId == "CCN" && !statusFile ) {
                                return true;
                            }

                            return false;
                        }
                    }
                },
                messages: {
                    name: {
                        required: "Nome richiesto.",
                    },
                    quotationNumber: {
                        required: "Numero richiesto."
                    },
                    lang: {
                        required: "Lingua richiesta."
                    },
                    validityDate: {
                        required: "Data validità richiesta."
                    },

                    requireAnyOfCustomerLeadOrOpportunity: {
                        required: "Compilare almeno un campo fra cliente, lead o opportunità"
                    },

                    status: {
                        required: "Caricare il documento."
                    }

                }
            } );

            if ( thisForm.valid() ) {

                status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );
                const parsedData = viewModel.get( "detailForm.data" );

	                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/quotations",
                    data: JSON.stringify( parsedData ),
                    callback: {
                        done: function( xhr ) {

                            status.html( "" );
                            AP.widget.notify( "success", "Preventivo salvato correttamente." );

                            if ( viewModel.get( "detailForm.data.id" ) != "" ) {
                                window.location.reload();
                            } else {
                                window.location.href = "/manager/quotations/" + xhr.data.payload.id;
                            }
                        }
                    }
                } );
            }

            return false;
        },

    } );

    function clearAgentiFrom(n) {
        for (var i = n; i <= 5; i++) {
            viewModel.set("detailForm.data.agente" + i, null);
            viewModel.set("detailForm.data.commission" + i, null);
        }
    }

    function syncAgentiEnabled() {
        for (var i = 2; i <= 5; i++) {
            var prev = viewModel.get("detailForm.data.agente" + (i - 1));
            var prevId = prev ? (typeof prev === "object" ? prev.id : prev) : "";
            var enabled = !!(prevId && prevId !== "");
            viewModel.set("agente" + i + "Enabled", enabled);
            $("#agente-commission-" + i).prop("disabled", !enabled);
        }
    }

    pub.config = function() {
        return viewModel.get( "detailForm.data" );
    };

    pub.edit = function( id, onsSave ) {
        NM.util.openModal( $( "#quotation-header-modal" ) );

        // var status = $( "#quotation-header-modal .save-status" );

        AP.loading.show();

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/" + id,
            callback: {
                done: function( xhr ) {
                    viewModel.set( "detailForm.data", xhr.data );

                    setTimeout( function() {
                        syncAgentiEnabled();
                        AP.loading.hide();
                    }, 1000 );

                }
            }
        } );

        // $( "#quotationNameInput" ).prop( "readonly", true );
        $( "#quotationNumberInput" ).prop( "readonly", true );
        $( "#nav-general-tab" ).trigger( "click" );
    };

    pub.init = function() {

        kendo.bind( fields.headerRoot, viewModel );

        viewModel.get( "languages" ).data( AP.page.languages );
        viewModel.get( "statuses" ).data( AP.page.statuses );
        viewModel.get( "paymentMethods" ).data( AP.page.paymentMethods );
        viewModel.get( "currencies" ).data( AP.page.currencies );
        viewModel.get( "countries" ).data( AP.page.countries );
        viewModel.get( "states" ).data( AP.page.states );
        viewModel.get( "vatCodes" ).data( AP.page.vatCodes );

        AP.page.saleUsers.unshift( { "id": "", "name": "-- seleziona" } );

        viewModel.get( "saleUsers" ).data( AP.page.saleUsers );

        AP.page.techUsers.unshift( { "id": "", "name": "-- seleziona" } );

        viewModel.get( "techUsers" ).data( AP.page.techUsers );

        $( "#nav-status-tab" ).on( "click", function( event ) {
            $( "#nav-actual-tab" ).trigger( "click" );
        } );

		NM.util.ajax( {
			method: "GET",
			url: "/manager/ajax/accounts?hasAgenteVerticale=true",
			callback: {
				done: function( xhr ) {
					xhr.data.unshift( { id: "", name: "-- seleziona" } );
					viewModel.set( "agentiList", xhr.data );
					setTimeout( syncAgentiEnabled, 0 );
				},
			},
		} );

		viewModel.bind("change", function(e) {

			if (e.field === "detailForm.data.customer") {
				var customer = viewModel.get("detailForm.data.customer");
				var lingua = customer && typeof customer === "object" ? customer.lingua : null;
				if (lingua) {
					var lang = AP.page.languages.find(function(l) { return l.id === lingua; });
					if (lang) {
						viewModel.set("detailForm.data.lang", lang);
					}
				}
			}

			if (e.field === "detailForm.data.nessunAgente") {
				if (viewModel.get("detailForm.data.nessunAgente") == true) {
					clearAgentiFrom(1);
				}
				syncAgentiEnabled();
			}

			if (e.field === "detailForm.data.agente1") {
				var a = viewModel.get("detailForm.data.agente1");
				if (!a || !a.id) clearAgentiFrom(2);
				syncAgentiEnabled();
			}

			if (e.field === "detailForm.data.agente2") {
				var a = viewModel.get("detailForm.data.agente2");
				if (!a || !a.id) clearAgentiFrom(3);
				syncAgentiEnabled();
			}

			if (e.field === "detailForm.data.agente3") {
				var a = viewModel.get("detailForm.data.agente3");
				if (!a || !a.id) clearAgentiFrom(4);
				syncAgentiEnabled();
			}

			if (e.field === "detailForm.data.agente4") {
				var a = viewModel.get("detailForm.data.agente4");
				if (!a || !a.id) clearAgentiFrom(5);
				syncAgentiEnabled();
			}
		});
    };

    return pub;
} () );

