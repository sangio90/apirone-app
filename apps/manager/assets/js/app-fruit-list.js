AP.fruit = AP.fruit || {};
AP.fields.fruit = AP.fields.fruit || {};

AP.fields.fruit = {
    listRoot: $( "#fruit-list-root" ),
    detailRoot: $( "#fruit-detail-modal" ),
    attributesRoot: $( "#fruit-detail-root" ),
    detailForm: $( "#fruit-detail-form" ),
    searchListForm: $( "#fruit-grid-search-form" ),
};

$( document ).ready( function() {
    if ( AP.fields.fruit.listRoot.length ) {
        AP.fruit.list.init();
    }
} );

AP.fruit.list = ( function() {
    var pub = {};
    var fields = AP.fields.fruit;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/fruits" } ),
    };

    var defaultDetailForm = {
        data: {
            id: "",
            code: "",
            positionCount: "",
            selectedLines: [],
            nameItem: {
                id: "",
                name: "",
                lang: {
                    id: "IT",
                },
            },
            status: {
                id: "ACT",
            },
            category: {
                id: "",
            },
        },
        statuses: AP.page.statuses,
        lines: AP.page.lines,
        categories: AP.page.categories,

        title: "Carica frutto",
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,
        detailForm: defaultDetailForm,

        editPrices: function( event ) {

            var onSave = function() {
                viewModel.rows.read();
            };


            var item = {
                type: "productBase",
                id: event.data.id,
                name: event.data.name,
            };

            console.log( "editPrices", item );

            AP.price.modal.open( item, onSave );

        },

        resetForm: function() {
            viewModel.set( "detailForm", defaultDetailForm );
        },

        search: function( event ) {
            var thisForm = AP.fields.fruit.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;
        },

        attributes: function( event ) {
            var id = event.data.id;
            window.open( "/manager/products/" + id + "/detail", "_blank" ).focus();

            return false;
        },

        save: function( event ) {
            var thisForm = AP.fields.fruit.detailForm;
            var status = thisForm.find( ".status" );

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            if ( thisForm.valid() ) {
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/fruits",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
                                viewModel.get( "rows" ).read();
                                NM.util.autoHideMessage( status, "<span class='green'>Dimensione salvata</span>" );

                                setTimeout( () => fields.detailRoot.modal( "hide" ), 1500 );

                            }
                        },
                    },
                } );
            }

            return false;
        },

        new: function() {
            this.resetForm();

            NM.util.openModal( fields.detailRoot );
        },

        edit: function( event ) {

            console.log( "event", event );

            var selectedLines = [];

            viewModel.set( "detailForm.data", event.data );
            viewModel.set( "detailForm.title", "Modifica prodotto < " + event.data.code + " >" );

            if ( event.data.lines ) {
                for ( var line of event?.data?.lines ) {
                    selectedLines.push( line );
                }
            }

            viewModel.set( "detailForm.data.selectedLines", selectedLines );

            NM.util.openModal( fields.detailRoot );

            return false;
        },

        delete: function( event ) {
            var checks = $( "#fruit-grid" ).find( "[name=selected]:checked" );

            if ( checks.length ) {
                var values = [];

                checks.each( function() {
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/fruits",
                    data: ids,
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.data.payload.hasOwnProperty( "errors" ) ) {
                                AP.widget.notify( "error", "Non riesco a cancellare tutti i frutti" );
                            } else {
                                AP.widget.notify( "success", "Cancellazione avvenuta con successo" );
                            }

                            var id = viewModel.get( "detailForm.data.id" );

                            viewModel.rows.read();
                        },
                    },
                } );
            } else {
                AP.widget.notify( "warning", "Selezionare almeno un frutto" );
            }
        },
    } );

    pub.init = function() {
        kendo.bind( AP.fields.fruit.listRoot, viewModel );

        var detailForm = AP.fields.fruit.detailForm;

        AP.page.categories.unshift( {
            id: "",
            name: "-- Seleziona una categoria",
        } );

        detailForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                code: {
                    required: true,
                    maxlength: 10,
                    checkCode: true,
                    remote: {
                        url: "/manager/ajax/fruits/code-exists",
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
                positionCount: {
                    required: true,
                    digits: true,
                },
                name: {
                    required: true,
                },
                statusId: {
                    required: true,
                },
                categoryId: {
                    required: true,
                },
            },
            messages: {
                code: {
                    required: "Codice richiesto",
                    maxlength: "Al massimo 3 caratteri",
                    checkCode: "Solo numeri, lettere, trattino o trattino basso",
                    remote: "Il codice esiste",
                },
                positionCount: {
                    required: "Numero posizioni richieste",
                    digits: "Richiesto un valore intero",
                },
                name: {
                    required: "Descrizione richiesta",
                },
                statusId: {
                    required: "Status richiesto",
                },
                categoryId: {
                    required: "Categoria richiesta",
                },
            },
        } );
    };

    return pub;
} () );
