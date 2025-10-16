AP.fontFamily = AP.fontFamily || {};

AP.fontFamily.fields = {
    listRoot: $( "#line-list-root" ),
    detailRoot: $( "#line-detail-modal" ),
    detailForm: $( "#line-detail-form" ),
    searchListForm: $( "#line-grid-search-form" ),
    productsRoot: $( "#line-products-root" ),
    modelConfigModal: $( "#model-config-modal" ),
    modelConfigForm: $( "#model-config-form" ),
};

$( document ).ready( function() {
    if ( AP.fontFamily.fields.listRoot.length ) {
        AP.fontFamily.list.init();
    }

    if ( AP.fontFamily.fields.detailRoot.length ) {
        AP.fontFamily.products.init();
    }

} );

AP.fontFamily.detail = ( function() {
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
        },
        statuses: AP.page.statuses,
        categories: AP.page.categories,
        thicknesses: AP.page.thicknesses,
        title: "Carica linea",
    };

    // Helper per estrarre la traduzione
    function getText( texts, kind, lang ) {
        return texts.find(
            t => t.kind === kind && t.lang && t.lang.id === lang
        ) || { name: "" };
    }

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,

        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        // TESTARE
        getText: getText,

        // TESTARE
        setTextName: function( kind, lang, value ) {
            var texts = this.get( "detailForm.data.texts" );
            var item = texts.find( t => t.kind === kind && t.lang && t.lang.id === lang );
            if ( item ) {
                item.name = value;
                this.trigger( "change", { field: "detailForm.data.texts" } );
            }
        },

        resetForm: function() {
            var detailForm = AP.fontFamily.fields.detailForm;

            var validator = detailForm.validate();
            validator.resetForm();

            detailForm.find( ".status" ).html( "" );

            viewModel.set( "detailForm", defaultDetailForm );
        },

        save: function( event ) {
            var detailForm = AP.fontFamily.fields.detailForm;
            var status = detailForm.find( ".status" );

            status.html(
                "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>",
            );

            if ( detailForm.valid() ) {
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/lines",
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

    pub.new = function( { onSave } ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.resetForm();

        NM.util.openModal( AP.fontFamily.fields.detailRoot );
    };

    pub.edit = function( id, onSave ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.resetForm();

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/lines/" + id,
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

                        NM.util.openModal( AP.fontFamily.fields.detailRoot );
                    }
                },
            },
        } );
    };

    pub.init = function() {
        kendo.bind( AP.fontFamily.fields.detailRoot, viewModel );

        AP.page.categories.unshift( {
            id: "",
            name: "-- Seleziona una categoria",
        } );

        AP.page.thicknesses.unshift( {
            id: "",
            name: "-- Seleziona uno spessore",
        } );

        var detailForm = AP.fontFamily.fields.detailForm;

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
                        url: "/manager/ajax/font-families/pictogram-exists",
                        data: {
                            id: function() {
                                return viewModel.get( "detailForm.data.pic.id" );
                            },
                            fontFamily: function() {
                                return viewModel.get( "detailForm.data.font.id" );
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

AP.fontFamily.list = ( function() {
    var pub = {};

    var detailApp = AP.fontFamily.detail;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/lines" } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        search: function( event ) {
            var thisForm = AP.fontFamily.fields.searchListForm;

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

            detailApp.new( onSave );

            return false;
        },

        edit: function( event ) {
            var onSave = function() {
                viewModel.get( "rows" ).read();
            };

            detailApp.edit( event.data.id, onSave );

            return false;
        },

        delete: function( event ) {
            var checks = $( "#line-grid" ).find( "[name=selected]:checked" );

            if ( checks.length ) {
                var values = [];

                checks.each( function() {
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/lines",
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
            window.open( "/manager/lines/" + id + "/products", "_blank" ).focus();

            return false;
        },

        attributes: function( event ) {

            var id = event.data.id;
            window.open( "/manager/lines/" + id + "/attributes", "_blank" ).focus();

            return false;
        },
    } );

    pub.init = function() {
        kendo.bind( AP.fontFamily.fields.listRoot, viewModel );
    };

    return pub;
} () );
