AP.namespace( "lineCost" );

Object.assign( AP.lineCost.fields, {
    listRoot: $( "#line-cost-list-root" ),
    detailRoot: $( "#line-cost-modal-root" ),
} );

$( document ).ready( function() {
    if ( AP.lineCost.fields.listRoot.length ) {
        AP.lineCost.list.init();
    }
} );

AP.lineCost.list = ( function() {
    var pub = {};

    var fields = AP.lineCost.fields;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/lines/costs" } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        search: function( event ) {
            var thisForm = fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;
        },

    } );

    pub.init = function() {
        kendo.bind( fields.listRoot, viewModel );
    };

    return pub;
} () );
