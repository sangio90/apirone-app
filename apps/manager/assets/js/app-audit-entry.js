AP.auditEntry = AP.auditEntry || {};

AP.auditEntry.fields = {
    listRoot: $( "#audit-entry-list-root" ),
    detailRoot: $( "#audit-entry-detail-modal" ),
    searchListForm: $( "#audit-entry-search-form" ),
};

$( document ).ready( function() {
    if ( AP.auditEntry.fields.listRoot.length ) {
        AP.auditEntry.list.init();
    }

} );

AP.auditEntry.list = ( function() {
    var pub = {};

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/audit-entries" } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,
        detailForm: {
            data: undefined
        },

        getCreatedAt: function( event ) {
            return NM.kendo.formatDate( event.createdAt );
        },

        search: function( event ) {
            var thisForm = AP.auditEntry.fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;
        },

        show: function( event ) {

            var id = event.data.id;

            viewModel.set( "detailForm.title", "Dettaglio < " + id + " >" );

            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/audit-entries/" + id,
                callback: {
                    done: function( xhr ) {
                        if ( xhr.status == "SUCCESS" ) {

                            viewModel.set( "detailForm.data", xhr.data );
                            viewModel.set( "detailForm.data.payload", JSON.stringify( xhr.data.payload, null, 4 ) );

                            NM.util.openModal( AP.auditEntry.fields.detailRoot );
                        }
                    },
                },
            } );

            return false;
        },

    } );

    pub.init = function() {
        kendo.bind( AP.auditEntry.fields.listRoot, viewModel );
    };

    return pub;
} () );

