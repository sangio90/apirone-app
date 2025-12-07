AP.namespace( "article" );

Object.assign( AP.article.fields, {
    listRoot: $( "#article-list-root" ),
    detailRoot: $( "#article-detail-root" )
} );

$( document ).ready( function() {

    if ( AP.article.fields.listRoot.length ) {
        AP.article.list.init();
    }

} );

AP.article.detail = ( function() {
    var pub = {};
    var fields = AP.article.fields;

    var defaultDetailForm = {
        data: {
            id: "",
            code: "",
            externalId: "",
            name: "",
            type: {
                id: "SER",
            },
            nameItem: {
                id: "",
                name: "",
                lang: {
                    id: "IT"
                }
            },
            descriptionItem: {
                id: "",
                name: "",
                lang: {
                    id: "IT"
                }
            },
            status: {
                id: "ACT",
            },
            price: {
                id: "",
                amount: ""
            }
        },
        types: AP.page.types,
        statuses: AP.page.statuses,
        title: "Carica servizio",
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,

        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        resetForm: function() {
            var detailForm = fields.detailRoot.find( "#article-detail-form" );

            var validator = detailForm.validate();
            validator.resetForm();

            detailForm.find( ".status" ).html( "" );

            viewModel.set( "detailForm", defaultDetailForm );
        },

        save: function( event ) {
            var detailForm = fields.detailRoot.find( "#article-detail-form" );

            var status = detailForm.find( ".status" );

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            if ( detailForm.valid() ) {
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/articles",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {
                            NM.util.autoHideMessage( status, "<span class='green'>Valore salvato</span>" );

                            setTimeout( () => {
                                $( "#article-detail-root" ).modal( "hide" );
                            }, 1000 );

                            AP.util.fireCallback(
                                "onSave",
                                viewModel.get( "callback" ),
                            );
                        },
                    },
                } );
            }

            return false;
        },
    } );

    pub.new = function( { onSave } ) {

        init();

        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.resetForm();

        NM.util.openModal( fields.detailRoot );
    };

    pub.edit = function( { id, onSave } ) {

        init();

        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.resetForm();

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/articles/" + id,
            callback: {
                done: function( xhr ) {

                    viewModel.set( "detailForm.data", xhr.data );
                    viewModel.set( "detailForm.title", "Modifica articolo" );

                    NM.util.openModal( fields.detailRoot );
                },
            },
        } );
    };

    var init = function() {

        kendo.bind( fields.detailRoot, viewModel );

        var detailForm = fields.detailRoot.find( "#article-detail-form" );

        detailForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                code: {
                    required: true,
                    checkCode: true,
                    maxlength: 10,
                    remote: {
                        url: "/manager/ajax/articles/code-exists",
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
                    maxlength: "Al massimo 10 caratteri",
                    checkCode: "Solo numeri, lettere, trattino o trattino basso",
                    remote: "Il codice esiste",
                },
            },
        } );
    };

    return pub;
} () );

AP.article.list = ( function() {
    var pub = {};

    var detailApp = AP.article.detail;
    var fields = AP.article.fields;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/articles" } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        search: function( event ) {
            var thisForm = $( "#article-grid-search-form" );

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
            var checks = $( "#article-grid" ).find( "[name=selected]:checked" );

            if ( checks.length ) {
                var values = [];

                checks.each( function() {
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/articles",
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
        kendo.bind( fields.listRoot, viewModel );
    };

    return pub;
} () );
