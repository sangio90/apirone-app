AP.price = AP.price || {};
AP.fields.price = AP.fields.price || {};

AP.fields.price = {
    manageRoot: $( "#price-manage-root" ),
};

$( document ).ready( function(){

    if ( AP.fields.price.manageRoot.length ) {
        AP.price.manage.init();
    }

} );

AP.price.manage = ( function() {

    var pub = {};
    var fields = AP.fields.price;

    var viewModel = kendo.observable( {

        resetForm: function() {
            viewModel.set( "detailForm", defaultDetailForm );
        },

        attributes: function( event ) {
            var id = event.data.id;
            window.open( "/manager/products/" + id + "/detail", "_blank" ).focus();

            return false;
        },

        search: function( event ) {

            var thisForm = AP.fields.price.searchListForm;

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

        console.log( "price:manage" );

        kendo.bind( AP.fields.price.listRoot, viewModel );

    };

    return pub;
}() );
