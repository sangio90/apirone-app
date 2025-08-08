AP.auditEntry = AP.auditEntry || {};

AP.auditEntry.fields = {
    listRoot: $( "#audit-entry-list-root" ),
    detailRoot: $( "#audit-entry-detail-modal" ),
    detailForm: $( "#audit-entry-detail-form" ),
    searchListForm: $( "#audit-entry-grid-search-form" ),
};

$( document ).ready( function() {
    if ( AP.auditEntry.fields.listRoot.length ) {
        AP.auditEntry.list.init();
    }

    if ( AP.auditEntry.fields.detailRoot.length ) {
        AP.auditEntry.detail.init();
    }
} );

AP.auditEntry.detail = ( function() {
    var pub = {};

    var viewModel = kendo.observable( {
        detailForm: {},
    } );

    pub.view = function( { onSave } ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.resetForm();

        NM.util.openModal( AP.auditEntry.fields.detailRoot );
    };

    pub.init = function() {
        kendo.bind( AP.auditEntry.fields.detailRoot, viewModel );
    };

    return pub;
} () );

AP.auditEntry.list = ( function() {
    var pub = {};

    var detailApp = AP.auditEntry.detail;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/audit-entries" } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        search: function( event ) {
            var thisForm = AP.auditEntry.fields.searchListForm;

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

    } );

    pub.init = function() {
        kendo.bind( AP.auditEntry.fields.listRoot, viewModel );
    };

    return pub;
} () );

