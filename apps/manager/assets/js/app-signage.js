AP.namespace( "signage" );

Object.assign( AP.signage.fields, {
    modalRoot: $( "#signage-modal" )
} );

$( document ).ready( function() {
    if ( AP.signage.fields.modalRoot.length ) {
        AP.signage.modal.init();
    }
} );

AP.signage.modal = ( function() {
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
        title: "Carica segnaletica",
    };

    // Helper per estrarre la traduzione
    function getText( texts, kind, lang ) {
        return texts.find(
            t => t.kind === kind && t.lang && t.lang.id === lang
        ) || { name: "" };
    }

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,
        categories: new Kendo.data.DataSource(),

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

        resetForm: function() {},

        save: function( event ) {
            var detailForm = AP.signage.fields.detailForm;
            var status = detailForm.find( ".status" );

            status.html(
                "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>",
            );

            if ( detailForm.valid() ) {
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/signages",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
                                NM.util.autoHideMessage(
                                    status,
                                    "<span class='green'>Segnaletica salvata</span>",
                                );

                                setTimeout(
                                    () => $( "#signage-detail-modal" ).modal( "hide" ),
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

    pub.open = function( id, onSave ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        NM.util.ajax( {
            method: "GET",
            url: "/ajax/quotations/categories",
            callback: {
                done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {
                        
                        viewModel.get( "categories" ).data( xhr.data );

                        NM.util.openModal( AP.signage.fields.modalRoot );
                    }
                },
            },
        } );
    };

    pub.edit = function( { id, onSave } ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.resetForm();

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/signages/" + id,
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
                        viewModel.set( "detailForm.title", "Modifica segnaletica" );

                        NM.util.openModal( AP.signage.fields.detailRoot );
                    }
                },
            },
        } );
    };

    pub.init = function() {
        kendo.bind( AP.signage.fields.detailRoot, viewModel );
    };

    return pub;
} () );
