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
            shippingAddress: {
                id: null,
                name: ""
            },
            quotationNumber: "",
            versionNumber: 1,
            lang: {
                id: "IT"
            },
            zone: {
                id: "",
                name: ""
            },
            quotationDate: new Date(),
            validityDate: new Date(),
            notes: "",
            status: {
                id: "LAV"
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
            vatNumber: "",
            currency: {
                id: 1
            },
            vatCode: {
                id: 22
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
        },
        title: "Modifica preventivo",
        totals: {
            "id": null
        }
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,
        languages: new kendo.data.DataSource(),
        varCodes: new kendo.data.DataSource(),
        statuses: new kendo.data.DataSource(),
        vatCodes: new kendo.data.DataSource(),
        pricelists: new kendo.data.DataSource(),
        paymentMethods: new kendo.data.DataSource(),
        currencies: new kendo.data.DataSource(),
        countries: new kendo.data.DataSource(),
        states: new kendo.data.DataSource(),
        quotationItems: new kendo.data.DataSource(),

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
                        AP.widget.notify( "success", "Preventivo esportato correttamente." );
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

        save: function() {
            var thisForm = fields.haderForm;

            console.log( "fields.haderForm", fields.haderForm );

            var status = thisForm.find( ".save-status" );

            thisForm.validate( {
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

                            console.log( "lead", viewModel.get( "detailForm.data.lead" ) );

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
                            // window.location.href = "/manager/quotations/" + xhr.data.payload.id;
                        }
                    }
                } );
            }

            return false;
        },

    } );

    pub.config = function() {
        return viewModel.get( "detailForm.data" );
    };

    pub.edit = function( id, onsSave ) {
        NM.util.openModal( $( "#quotation-header-modal" ) );

        // var status = $( "#quotation-header-modal .save-status" );

        Loading.show();

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/" + id,
            callback: {
                done: function( xhr ) {

                    viewModel.set( "detailForm.data", xhr.data );

                    setTimeout( function() {
                        Loading.hide();
                    }, 1000 );

                }
            }
        } );


    };

    pub.init = function() {

        kendo.bind( fields.headerRoot, viewModel );

        console.log( "headerRoot:init" );

        viewModel.get( "languages" ).data( AP.page.languages );
        viewModel.get( "statuses" ).data( AP.page.statuses );
        viewModel.get( "paymentMethods" ).data( AP.page.paymentMethods );
        viewModel.get( "currencies" ).data( AP.page.currencies );
        viewModel.get( "countries" ).data( AP.page.countries );
        viewModel.get( "states" ).data( AP.page.states );
        viewModel.get( "vatCodes" ).data( AP.page.vatCodes );

    };

    return pub;
} () );

