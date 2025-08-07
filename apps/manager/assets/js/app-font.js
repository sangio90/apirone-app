AP.font = AP.font || {};

AP.font.fields = {
    listRoot: $( "#font-list-root" ),
    searchListForm: $( "#font-grid-search-form" ),
    detailRoot: $( "#font-detail-modal" ),
    detailForm: $( "#font-detail-form" ),
};

$( document ).ready( function() {
    if ( AP.font.fields.listRoot.length ) {
        AP.font.list.init();
    }
    if ( AP.font.fields.detailRoot.length ) {
        AP.font.detail.init();
    }
} );

AP.font.detail = ( function() {
    var pub = {};

    var defaultDetailForm = {
        data: {
            id: "",
            code: "",
            directory: "",
            dimension: 0,
            mainText: {
                id: "",
                name: "",
                lang: {
                    id: "IT",
                },
            }
        },


        title: "Carica font",
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,

        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        resetForm: function() {
            var detailForm = AP.font.fields.detailForm;

            var validator = detailForm.validate();
            validator.resetForm();

            detailForm.find( ".status" ).html( "" );

            viewModel.set( "detailForm", defaultDetailForm );
        },

        save: function( event ) {
            var detailForm = AP.font.fields.detailForm;
            var status = detailForm.find( ".status" );

            status.html(
                "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>",
            );

            if ( detailForm.valid() ) {
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/fonts",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
                                NM.util.autoHideMessage(
                                    status,
                                    "<span class='green'>Font salvato</span>",
                                );

                                setTimeout(
                                    () => $( "#font-detail-modal" ).modal( "hide" ),
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

    pub.new = function( { onSave } ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.resetForm();

        NM.util.openModal( AP.font.fields.detailRoot );
    };

    pub.edit = function( { id, onSave } ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.resetForm();

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/fonts/" + id,
            callback: {
                done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {

                        viewModel.set( "detailForm.data", xhr.data );
                        viewModel.set( "detailForm.title", "Modifica font < " + xhr.data.name + " >" );

                        NM.util.openModal( AP.font.fields.detailRoot );
                    }
                },
            },
        } );
    };

    pub.init = function() {
        kendo.bind( AP.font.fields.detailRoot, viewModel );

        var detailForm = AP.font.fields.detailForm;

        detailForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                name: {
                    required: true,
                    rangelength: [ 2, 100 ]
                },
                code: {
                    required: true,
                    checkCode: true,
                    remote: {
                        url: "/manager/ajax/fonts/code-exists",
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
                name: {
                    required: "Nome richiesto",
                    rangelength: "Sono richiesti tra 2 e 100 caratteri"
                },
                code: {
                    required: "Codice richiesto",
                    checkCode: "Solo numeri, lettere, trattino o trattino basso",
                    remote: "Il codice esiste",
                },
            },
        } );
    };

    return pub;
} () );

AP.font.list = ( function() {
    var pub = {};

    var detailApp = AP.font.detail;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/fonts" } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        search: function( event ) {
            var thisForm = AP.font.fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;
        },

        new: function( event ) {
            var onSave = function() {
                viewModel.get( "rows" ).read();
            };

            detailApp.new( { onSave: onSave } );

            return false;
        },


        edit: function( event ) {
            var onSave = function() {
                viewModel.get( "rows" ).read();
            };

            detailApp.edit( { id: event.data.id, onSave: onSave } );

            return false;
        },

        delete: function( event ) {
            var checks = $( "#font-grid" ).find( "[name=selected]:checked" );

            if ( checks.length ) {
                var values = [];

                checks.each( function() {
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/fonts",
                    data: ids,
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.data.payload.hasOwnProperty( "errors" ) ) {
                                AP.widget.notify(
                                    "error",
                                    "Non riesco a cancellare tutti i valori",
                                );
                            } else {
                                AP.widget.notify(
                                    "success",
                                    "Cancellazione avvenuta con successo",
                                );
                            }

                            var id = viewModel.get( "detailForm.data.id" );
                            console.log( "id", id );

                            viewModel.rows.read();
                        },
                    },
                } );
            } else {
                AP.widget.notify( "warning", "Seleziona almeno un valore" );
            }
        },
    } );

    pub.init = function() {
        kendo.bind( AP.font.fields.listRoot, viewModel );

    };

    return pub;
} () );
