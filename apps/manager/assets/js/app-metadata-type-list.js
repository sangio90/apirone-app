AP.namespace( "metadataType" );

Object.assign( AP.metadataType.fields, {
    listRoot: $( "#metadata-type-list-root" ),
} );

/*
AP.metadataType = AP.metadataType || {};

Object.assign( AP.namespace( "metadataType" ), {
    listRoot: $( "#metadata-type-list-root" ),
} );
*/

$( document ).ready( function() {
    if ( AP.metadataType.fields.listRoot.length ) {
        AP.metadataType.list.init();
    }
} );

AP.metadataType.list = ( function() {
    var pub = {};

    var detailApp = AP.metadataType.detail;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/metadata-types" } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        search: function( event ) {
            var thisForm = AP.metadataType.fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;
        },

        new: function() {

            detailApp.new();
        },

        edit: function( event ) {
            // viewModel.resetForm();

            console.log( "event.data.id", event.data.id );

            var onSave = function() {
                viewModel.get( "rows" ).read();
            };

            detailApp.edit( event.data.id, onSave );

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

    } );

    pub.init = function() {
        kendo.bind( AP.metadataType.fields.listRoot, viewModel );
    };

    return pub;
} () );


