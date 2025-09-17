AP.namespace( "catalogBundle" );

Object.assign( AP.catalogBundle.fields, {
    listRoot: $( "#catalog-bundle-list-root" ),
    detailRoot: $( "#catalog-bundle-detail-modal" ),
    detailForm: $( "#catalog-bundle-detail-form" ),
} );

$( document ).ready( function() {
    if ( AP.catalogBundle.fields.listRoot.length ) {
        AP.catalogBundle.list.init();
    }

    if ( AP.catalogBundle.fields.detailRoot.length ) {
        AP.catalogBundle.detail.init();
    }
} );

AP.catalogBundle.detail = ( function() {
    var pub = {};

    var defaultDetailForm = {
        data: {
            id: "",
            price: "",
        },
        title: "Modifica bundle",
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,

        save: function( event ) {
            var detailForm = AP.catalogBundle.fields.detailForm;
            var status = detailForm.find( ".status" );

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            if ( detailForm.valid() ) {
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/catalog-bundles",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
                                NM.util.autoHideMessage(
                                    status,
                                    "<span class='green'>Linea salvata</span>",
                                );

                                setTimeout(
                                    () => $( "#line-detail-modal" ).modal( "hide" ),
                                    1000,
                                );

                                AP.util.fireCallback(
                                    "onSave",
                                    viewModel.get( "callback" ),
                                );
                            }
                        },
                    },
                } );
            }

            return false;
        },
    } );

    pub.edit = function( { id, onSave } ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.resetForm();

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/catalog-bundles/" + id,
            callback: {
                done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {
                        NM.util.openModal( AP.catalogBundle.fields.detailRoot );
                    }
                },
            },
        } );
    };

    pub.init = function() {
        kendo.bind( AP.catalogBundle.fields.detailRoot, viewModel );

        var detailForm = AP.catalogBundle.fields.detailForm;

        detailForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                code: {
                    required: true,
                    checkCode: true,
                    rangelength: [ 5, 5 ],
                    remote: {
                        url: "/manager/ajax/lines/code-exists",
                        data: {
                            id: function() {
                                return viewModel.get( "detailForm.data.id" );
                            },
                        },
                        dataFilter: function( xhr ) {
                            var json = JSON.parse( xhr );
                            return json.data == false;
                        },
                    },
                },
            },
            messages: {
                code: {
                    required: "Codice richiesto",
                    rangelength: "Sono richiesti 5 caratteri",
                    checkCode: "Solo numeri, lettere, trattino o trattino basso",
                    remote: "Il codice esiste",
                },
            },
        } );
    };

    return pub;
} () );

AP.catalogBundle.list = ( function() {
    var pub = {};

    var detailApp  = AP.catalogBundle.detail;

    var viewModel = kendo.observable( {
        rows: NM.kendo.dataSource( { url: "/manager/ajax/catalog-bundles" } ),

        getCreatedAt: function( event ) {
            return NM.kendo.formatISODate( event.createdAt );
        },

        search: function( event ) {
            var thisForm = AP.catalogBundle.fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;
        },

        edit: function( event ) {
            var onSave = function() {
                viewModel.get( "rows" ).read();
            };

            detailApp.edit( { id: event.data.id, onSave: onSave } );

            return false;
        },

    } );

    pub.init = function() {
        kendo.bind( AP.catalogBundle.fields.listRoot, viewModel );
    };

    return pub;
} () );

