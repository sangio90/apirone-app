AP.namespace( "globalMetadata" );

Object.assign( AP.globalMetadata.fields, {
    listRoot: $( "#global-metadata-list-root" ),
    searchListForm: $( "#global-metadata-list-search-form" ),
} );

$( document ).ready( function() {
    if ( AP.globalMetadata.fields.listRoot.length ) {
        AP.globalMetadata.list.init();
    }
} );

AP.globalMetadata.list = ( function() {
    var pub = {};

    var fields = AP.globalMetadata.fields;
    var detailApp = AP.globalMetadata.detail;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/global-metadata" } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        getCreatedAt: function( event ) {
            return NM.kendo.formatISODate( event.createdAt );
        },

        save: function( event ) {

            // var ids = values.toString();

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/global-metadata",
                data: JSON.stringify( viewModel.get( "rows" ) ),
                callback: {
                    done: function( xhr ) {
                        AP.widget.notify( "success", "Dati aggiornati" );
                        viewModel.rows.read();
                    },
                },
            } );
        },
    } );

    pub.init = function() {
        kendo.bind( fields.listRoot, viewModel );
    };

    return pub;
} () );


