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

    var defaultDetailForm = {
        data: {
            id: "",
            name: "",
            number: "",
            version: 1,
            language: {
                "id":""
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
                    console.log(xhr)
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
    } )

    pub.init = function() {
        viewModel.get( "languages" ).data( AP.page.languages )
        viewModel.get( "statuses" ).data( AP.page.statuses )
        viewModel.get( "pricelists" ).data( AP.page.pricelists )
        viewModel.get( "paymentMethods" ).data( AP.page.paymentMethods )
        viewModel.get( "currencies" ).data( AP.page.currencies )
        viewModel.get( "countries" ).data( AP.page.countries )
        viewModel.get( "states" ).data( AP.page.states )
        kendo.bind( AP.quotationDetail.fields.detailRoot, viewModel );
    };
    
    return pub;
} () );