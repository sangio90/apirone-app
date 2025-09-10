AP.product = AP.product || {};
AP.fields.product = AP.fields.product || {};

AP.fields.product = {
    listRoot: $( "#product-list-root" ),
    detailRoot: $( "#product-detail-modal" ),
    attributesRoot: $( "#product-detail-root" ),
    detailForm: $( "#product-detail-form" ),
    searchListForm: $( "#product-grid-search-form" ),
};

$( document ).ready( function(){

    if ( AP.fields.product.listRoot.length ) {
        AP.product.list.init();
    }

} );

AP.product.list = ( function() {

    var pub = {};
    var fields = AP.fields.product;
    var detailApp = AP.product.detail;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/products" } )
    };

    var defaultDetailForm = {
        data: {
            id: "",
            code: "",
            positionCount: "",
            category: {
                id: 167 // TODO: add dynamic value according to current category
            },
            nameItem: {
                id: "",
                name: "",
                lang: {
                    id: "IT"
                }
            },
            status: {
                id: "ACT"
            }
        },
        statuses: AP.page.statuses,

        title: "Carica prodotto"
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,
        detailForm: defaultDetailForm,

        resetForm: function() {
            viewModel.set( "detailForm", defaultDetailForm );
        },

        attributes: function( event ) {
            var id = event.data.id;
            window.open( "/manager/products/" + id + "/detail", "_blank" ).focus();

            return false;
        },

        search: function( event ) {

            var thisForm = AP.fields.product.searchListForm;

            console.log( "searchListForm", thisForm );

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;

        },

        print: function( event ) {

            var target = $( event.currentTarget );
            var report = target.data( "report" );

            var qs = $( "#product-grid-search-form" ).serialize();

            var id = event.data.id;
            window.open( "/manager/products/print/" + report + "?" + qs, "_blank" ).focus();

            return false;
        },

    } );

    pub.init = function() {

        kendo.bind( AP.fields.product.listRoot, viewModel );

    };

    return pub;
}() );
