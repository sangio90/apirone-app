AP.model = AP.model || {};

AP.model.fields = {
    listRoot: $( "#model-list-root" ),
    detailForm: $( "#model-detail-form" ),
    searchListForm: $( "#model-grid-search-form" ),
};

$( document ).ready( function() {
    if ( AP.model.fields.listRoot.length ) {
        AP.model.list.init();
    }
} );

AP.model.list = ( function() {
    var pub = {};

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/models" } ),
    };

    var defaultDetailForm = {
        data: {
            id: "",
            code: "",
            fruitsCount: "",
            selectedCategories: [],
            type: {
                id: "",
            },
            nameItem: {
                id: "",
                name: "",
                lang: {
                    id: "IT",
                },
            },
            descriptionItem: {
                id: "",
                name: "",
                lang: {
                    id: "IT",
                },
            },
            status: {
                id: "ACT",
            },
        },
        statuses: AP.page.statuses,
        categories: AP.page.categories,
        types: AP.page.types,

        title: "Carica modello",
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,
        detailForm: defaultDetailForm,

        resetForm: function() {
            viewModel.set( "detailForm", defaultDetailForm );
        },

        search: function( event ) {
            var thisForm = AP.model.fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;
        },

        save: function( event ) {
            var thisForm = AP.model.fields.detailForm;
            var status = thisForm.find( ".status" );

            status.html( "<img src=\"/assets/main/img/ajax-loading.svg\" width=\"20\" height=\"20\">" );

            if ( thisForm.valid() ) {
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/models",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
                                viewModel.get( "rows" ).read();
                                NM.util.autoHideMessage( status, "<span class='green'>Dimensione salvata</span>" );

                                setTimeout( () => $( "#model-detail-modal" ).modal( "hide" ), 1500 );
                            }
                        },
                    },
                } );
            }

            return false;
        },

        new: function( event ) {
            this.resetForm();

            NM.util.openModal( $( "#model-detail-modal" ) );
        },

        edit: function( event ) {
            viewModel.set( "detailForm.data", event.data );
            viewModel.set( "detailForm.title", "Modifica modello < " + event.data.code + " >" );

            var selectedCategories = [];

            if ( event.data.categories ) {
                for ( var category of event?.data?.categories ) {
                    selectedCategories.push( category );
                }
            }

            viewModel.set( "detailForm.data.selectedCategories", selectedCategories );

            NM.util.openModal( $( "#model-detail-modal" ) );
        },

        delete: function( event ) {
            var checks = $( "#model-grid" ).find( "[name=selected]:checked" );

            if ( checks.length ) {
                var values = [];

                checks.each( function() {
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/models",
                    data: ids,
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.data.payload.hasOwnProperty( "errors" ) ) {
                                AP.widget.notify( "error", "Non riesco a cancellare tutte le dimensioni" );
                            } else {
                                AP.widget.notify( "success", "Cancellazione avvenuta con successo" );
                            }

                            var id = viewModel.get( "detailForm.data.id" );

                            viewModel.rows.read();
                        },
                    },
                } );
            } else {
                AP.widget.notify( "warning", "Selezionare almeno una dimensione" );
            }
        },
    } );

    pub.init = function() {
        kendo.bind( AP.model.fields.listRoot, viewModel );

        var detailForm = AP.model.fields.detailForm;

        AP.page.types.unshift( { id: "", name: "-- Seleziona il tipo" } );

        detailForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                name: {
                    required: true,
                },
                typeId: {
                    required: true,
                },
                fruitsCount: {
                    number: true,
                    required: true,
                },
                code: {
                    required: true,
                    maxlength: 3,
                    checkCode: true,
                    remote: {
                        url: "/manager/ajax/models/code-exists",
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
                    required: "Descrizione richiesta",
                },
                typeId: {
                    required: "Tipo richiesto",
                },
                fruitsCount: {
                    number: "Richiesto un valore intero",
                    required: "Valore richiesto",
                },
                code: {
                    required: "Codice richiesto",
                    maxlength: "Al massimo 3 caratteri",
                    checkCode: "Solo numeri, lettere, trattino o trattino basso",
                    remote: "Il codice esiste",
                },
            },
        } );
    };

    return pub;
} () );
