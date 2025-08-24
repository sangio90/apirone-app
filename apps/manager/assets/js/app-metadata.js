AP.namespace( "metadata" );

Object.assign( AP.metadata.fields, {
    detailRoot: $( "#metadata-modal-root" ),
} );

$( document ).ready( function() {
    if ( AP.metadata.fields.detailRoot.length ) {
        AP.metadata.detail.init();
    }
} );

AP.metadata.detail = ( function() {
    var pub = {};

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/metadata" } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        search: function( event ) {
            var thisForm = AP.metadata.fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;
        },

        edit: function( event ) {

            console.log( "event.data.id", event.data.id );

            var onSave = function() {
                viewModel.get( "rows" ).read();
            };

            detailApp.edit( event.data.id, onSave );

            return false;
        },

        save: function( event ) {
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

        showList: function( event ) {

            // viewModel.set( "showSearchPanel", true );

            return false;
        },


    } );

    pub.open = function( item ) {

        viewModel.set( "currentItem", item );

        // viewModel.showList();

        var onDone = function() {
            NM.util.openModal( $( "#component-list-modal" ) );
        };

        // refreshSelectedComponents( onDone=onDone );

    };

    pub.init = function() {
        kendo.bind( AP.metadata.fields.listRoot, viewModel );
    };

    return pub;
} () );


