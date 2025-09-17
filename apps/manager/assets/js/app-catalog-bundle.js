AP.namespace( "catalogBundle" );

Object.assign( AP.catalogBundle.fields, {
    listRoot: $( "#catalog-bundle-list-root" ),
    searchForm: $( "#catalog-bundle-grid-search-form" ),
    detailRoot: $( "#catalog-bundle-detail-modal" ),
    detailForm: $( "#catalog-bundle-detail-form" ),
} );

$( document ).ready( function() {
    if ( AP.catalogBundle.fields.listRoot.length ) {
        AP.catalogBundle.list.init();
    }

} );

AP.catalogBundle.list = ( function() {
    var pub = {};

    var detailApp  = AP.catalogBundle.detail;
    var fields  = AP.catalogBundle.fields;

    var viewModel = kendo.observable( {
        rows: NM.kendo.dataSource( { url: "/manager/ajax/catalog-bundles" } ),

        getCreatedAt: function( event ) {
            return NM.kendo.formatISODate( event.createdAt );
        },

        search: function( event ) {
            var thisForm = fields.searchForm;

            var params = thisForm.serializeJSON();
            params.page = 1;

            viewModel.rows.read( params );

            return false;
        },

        edit: function( event ) {
            var onSave = function() {
                viewModel.get( "rows" ).read();
            };

            detailApp.edit( { id: event.data.id, onSave: onSave } );

            return false;
        },

        save: function( event ) {
            var status = $( "#catalog-bindle-save-status" );

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/catalog-bundles",
                data: JSON.stringify( viewModel.get( "rows" ) ),
                callback: {
                    done: function( xhr ) {

                        status.html( "" );

                        if ( xhr.data.payload.hasOwnProperty( "errors" ) ) {
                            AP.widget.notify( "error", "Non riesco a cancellare tutti i bundle" );
                        } else {
                            AP.widget.notify( "success", "Salvataggio avvenuta con successo" );
                        }

                        viewModel.rows.read();
                    },
                },
            } );

            return false;
        },
    } );

    pub.init = function() {
        kendo.bind( fields.listRoot, viewModel );
    };

    return pub;
} () );

