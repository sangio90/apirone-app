AP.line = AP.line || {};

AP.line.fields = {
    listRoot: $( "#metadata-type-list-root" ),
    detailRoot: $( "#metadata-type-detail-modal" ),
    detailForm: $( "#metadata-type-detail-form" ),
    searchListForm: $( "#metadata-type-grid-search-form" ),
};

$( document ).ready( function() {
    if ( AP.line.fields.listRoot.length ) {
        AP.line.list.init();
    }

    if ( AP.line.fields.detailRoot.length ) {
        AP.line.detail.init();
    }
} );

AP.line.detail = ( function() {
    var pub = {};

    var defaultDetailForm = {
        data: {
            id: "",
            code: "",
            name: "",
            selectedCategories: [],
            category: {
                id: "",
            },
            unit: {
                id: "",
            },
            status: {
                id: "ACT",
            },
        },
        units: AP.page.units,
        statuses: AP.page.statuses,
        title: "Carica tipo di metadato",
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,

        callbacks: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        resetForm: function() {
            var detailForm = AP.line.fields.detailForm;

            var validator = detailForm.validate();
            validator.resetForm();

            detailForm.find( ".status" ).html( "" );

            viewModel.set( "detailForm", defaultDetailForm );
        },

        save: function( event ) {
            var detailForm = AP.line.fields.detailForm;
            var status = detailForm.find( ".status" );

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            if ( detailForm.valid() ) {
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/metadata-types",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
                                NM.util.autoHideMessage(
                                    status,
                                    "<span class='green'>Linea salvata</span>",
                                );

                                setTimeout(
                                    () => $( "#metadata-type-detail-modal" ).modal( "hide" ),
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

        NM.util.openModal( AP.line.fields.detailRoot );
    };

    pub.edit = function( { id, onSave } ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.resetForm();

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/metadata-types/" + id,
            callback: {
                done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {
                        var selectedCategories = [];

                        if ( xhr.data?.categories ) {
                            for ( var category of xhr.data.categories ) {
                                selectedCategories.push( category );
                            }
                        }

                        viewModel.set( "detailForm.data", xhr.data );
                        viewModel.set(
                            "detailForm.data.selectedCategories",
                            selectedCategories,
                        );
                        viewModel.set( "detailForm.title", "Modifica linea" );

                        NM.util.openModal( AP.line.fields.detailRoot );
                    }
                },
            },
        } );
    };

    pub.init = function() {
        kendo.bind( AP.line.fields.detailRoot, viewModel );

        AP.page.categories.unshift( {
            id: "",
            name: "-- Seleziona una categoria",
        } );

        AP.page.thicknesses.unshift( {
            id: "",
            name: "-- Seleziona uno spessore",
        } );

        var detailForm = AP.line.fields.detailForm;

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
                        url: "/manager/ajax/metadata-types/code-exists",
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

AP.line.list = ( function() {
    var pub = {};

    var detailApp = AP.line.detail;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/metadata-types" } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        search: function( event ) {
            var thisForm = AP.line.fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;
        },

        new: function( event ) {
            console.log( "detailApp", detailApp );

            var onSave = function() {
                console.log( "onSave" );
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
            var checks = $( "#metadata-type-grid" ).find( "[name=selected]:checked" );

            if ( checks.length ) {
                var values = [];

                checks.each( function() {
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/metadata-types",
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

        products: function( event ) {
            var id = event.data.id;
            window.open( "/manager/metadata-types/" + id + "/products", "_blank" ).focus();

            return false;
        },

        attributes: function( event ) {

            var id = event.data.id;
            window.open( "/manager/metadata-types/" + id + "/attributes", "_blank" ).focus();

            return false;
        },
    } );

    pub.init = function() {
        kendo.bind( AP.line.fields.listRoot, viewModel );
    };

    return pub;
} () );


