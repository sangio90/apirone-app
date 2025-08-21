AP.metadataType = AP.metadataType || {};

AP.metadataType.fields = {
    listRoot: $( "#metadata-type-list-root" ),
};

$( document ).ready( function() {
    if ( AP.metadataType.fields.listRoot.length ) {
        AP.metadataType.list.init();
    }
} );

AP.metadataType.list = ( function() {
    var pub = {};

    var detailApp = AP.metadataType.detail;
    var fields = AP.metadataType.fields;

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

        new: function() {
            viewModel.resetForm();

            NM.util.openModal( fields.detailRoot );
        },

        edit: function( event ) {
            viewModel.resetForm();

            viewModel.set( "detailForm.data", event.data );
            viewModel.set(
                "detailForm.title",
                "Modifica categoria <" + event.data.code + " >",
            );

            NM.util.openModal( fields.detailRoot );

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
        kendo.bind( AP.line.fields.listRoot, viewModel );
    };

    return pub;
} () );


