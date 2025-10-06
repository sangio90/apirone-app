AP.namespace( "priceType" );

Object.assign( AP.priceType.fields, {
    list: $( "#price-type-list-root" ),
    detail: $( "#price-type-detail-modal" ),
    detailForm: $( "#price-type-detail-form" ),
    searchListForm: $( "#price-type-grid-search-form" )
} );

$( document ).ready( function() {
    if ( AP.priceType.fields.list.length ) {
        AP.priceType.list.init();
    }

    if ( AP.priceType.fields.detail.length ) {
        AP.priceType.detail.init();
    }
} );

AP.priceType.detail = ( function() {
    var pub = {};
    var fields = AP.priceType.fields;

    var defaultDetailForm = {
        data: {
            id: "",
            name: "",
            selectedEntities: [],
            selectedMethods: [],
            status: {
                id: "ACT",
            },
        },
        isEdit: false,
        statuses: AP.page.statuses,
        entities: AP.page.entities,
        methods: AP.page.methods,
        title: "Carica tipo prezzo",
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,

        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        isDisabled: function() {

            return viewModel.get( "detailForm.isEdit" );

        },

        resetForm: function() {
            var detailForm = fields.detailForm;

            var validator = detailForm.validate();
            validator.resetForm();

            detailForm.find( ".status" ).html( "" );

            viewModel.set( "detailForm", defaultDetailForm );
        },

        save: function( event ) {
            var detailForm = AP.priceType.fields.detailForm;
            var status = detailForm.find( ".status" );

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            if ( detailForm.valid() ) {
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/prices/types",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {

                            status.html( "" );

                            setTimeout(
                                () => fields.detail.modal( "hide" ),
                                1000,
                            );

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

    pub.new = function( onSave ) {

        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.set( "detailForm.isEdit", false );

        viewModel.resetForm();

        NM.util.openModal( fields.detail );
    };

    pub.edit = function( id, onSave ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.resetForm();

        viewModel.set( "detailForm.isEdit", true );

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/prices/types/" + id,
            callback: {
                done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {

                        var selectedMethods = [];
                        var selectedEntities = [];

                        if ( xhr.data?.methods ) {
                            for ( var method of xhr.data.methods ) {
                                selectedMethods.push( method );
                            }
                        }

                        if ( xhr.data?.entities ) {
                            for ( var entity of xhr.data.entities ) {
                                selectedEntities.push( entity );
                            }
                        }

                        viewModel.set( "detailForm.data", xhr.data );
                        viewModel.set( "detailForm.data.selectedMethods", selectedMethods  );
                        viewModel.set( "detailForm.data.selectedEntities", selectedEntities  );
                        viewModel.set( "detailForm.title", "Modifica tipo prezzo < " + xhr.data.id + " >" );

                        NM.util.openModal( fields.detail );
                    }
                },
            },
        } );
    };

    pub.init = function() {

        kendo.bind( fields.detail, viewModel );

        var detailForm = fields.detailForm;

        detailForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                name: "required",
                id: {
                    required: true,
                    checkCode: true,
                    rangelength: [ 2, 14 ],
                    remote: {
                        url: "/manager/ajax/prices/types/exists",
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
                name: { required: "Nome richiesto" },
                id: {
                    required: "ID richiesto",
                    checkCode: "Solo numeri, lettere, trattino o trattino basso",
                    rangelength: "Sono richiesti almeno 2 caratteri",
                    remote: "Il codice esiste",
                },
            },
        } );
    };

    return pub;
} () );

AP.priceType.list = ( function() {
    var pub = {};

    var fields = AP.priceType.fields;
    var detailApp = AP.priceType.detail;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/prices/types" } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        search: function( event ) {
            var thisForm = fields.searchListForm;

            var params = thisForm.serializeJSON();

            console.log( "params", params );

            viewModel.rows.read( params );

            return false;
        },

        new: function( event ) {

            var onSave = function() {
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
            var checks = $( "#price-type-grid" ).find( "[name=selected]:checked" );

            if ( checks.length ) {
                var values = [];

                checks.each( function() {
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/prices/types",
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
        kendo.bind( fields.list, viewModel );
    };

    return pub;
} () );
