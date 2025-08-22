AP.namespace( "metadataType" );

Object.assign( AP.metadataType.fields, {
    detailRoot: $( "#metadata-type-detail-modal" ),
    detailForm: $( "#metadata-type-detail-form" ),
} );

$( document ).ready( function() {
    if ( AP.metadataType.fields.detailRoot.length ) {
        AP.metadataType.detail.init();
    }
} );

AP.metadataType.detail = ( function() {
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
        title: "Carica tipo di metadato",
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,

        units: AP.page.units,
        statuses: AP.page.statuses,
        dataTypes: AP.page.dataTypes,

        callbacks: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        resetForm: function() {
            var detailForm = AP.metadataType.fields.detailForm;

            var validator = detailForm.validate();
            validator.resetForm();

            detailForm.find( ".status" ).html( "" );

            viewModel.set( "detailForm", defaultDetailForm );
        },

        save: function( event ) {
            var detailForm = AP.metadataType.fields.detailForm;
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
                                NM.util.autoHideMessage( status, "<span class='green'>Metadato salvata</span>", );
                                setTimeout( () => $( "#metadata-type-detail-modal" ).modal( "hide" ), 600 );
                            }
                        },
                    },
                } );
            }

            return false;
        },
    } );

    pub.new = function() {

        viewModel.resetForm();

        NM.util.openModal( AP.metadataType.fields.detailRoot );
    };

    pub.edit = function(  id, onSave ) {
        if ( onSave ) {
            viewModel.set( "callbacks.onSave", onSave );
        }

        viewModel.resetForm();

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/metadata-types/" + id,
            callback: {
                done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {
                        var selectedEntities = [];

                        if ( xhr.data?.entities ) {
                            for ( var entity of xhr.data.entities ) {
                                selectedEntities.push( entity );
                            }
                        }

                        viewModel.set( "detailForm.data", xhr.data );
                        viewModel.set( "detailForm.data.selectedEntities", selectedEntities );
                        viewModel.set( "detailForm.title", "Modifica metadato" );

                        NM.util.openModal( AP.metadataType.fields.detailRoot );
                    }
                },
            },
        } );
    };

    pub.init = function() {

        var detailForm = AP.metadataType.fields.detailForm;

        /*
        AP.page.entities.unshift( {
            id: "",
            name: "-- Seleziona",
        } );
        */

        AP.page.units.unshift( {
            id: "",
            name: "-- Seleziona un'unità di misura",
        } );

        AP.page.dataTypes.unshift( {
            id: "",
            name: "-- Seleziona un tipo di dato",
        } );

        kendo.bind( AP.metadataType.fields.detailRoot, viewModel );

        detailForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                statusId: {
                    required: true,
                },
                dataTypeId: {
                    required: true,
                },
                unitId: {
                    required: true,
                },
                name: {
                    required: true,
                },
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
                unitId: {
                    required: "Stato richiesto",
                },
                statusId: {
                    required: "Stato richiesto",
                },
                dataTypeId: {
                    required: "Tipo di dato richiesto",
                },
                name: {
                    required: "Nome richiesto",
                },

            },
        } );
    };

    return pub;
} () );
