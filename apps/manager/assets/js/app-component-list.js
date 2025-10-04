AP.namespace( "component" );

Object.assign( AP.component.fields, {
    listRoot: $( "#component-list-root" ),
} );


$( document ).ready( function(){

    if ( AP.component.fields.listRoot.length ) {

        AP.component.list.init();

    }

} );

AP.component.list = ( function() {

    var pub = {};
    var fields = AP.component.fields;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/components" } ),
    };

    var viewModel = kendo.observable( {

        rows: dataSources.items,

        search: function( event ) {

            var thisForm = $( "#component-list-search-form" );
            var status = thisForm.find( ".status" );

            var requestStart = function() {
                status.html( "Sto cercando..." );
            };

            var requestEnd = function( xhr ) {
                status.html( "Ho trovato " + xhr.response.total + " componenti" );
            };

            var params = thisForm.serializeJSON();

            var dataSource = NM.kendo.dataSource( {
                url: "/manager/ajax/raw-products",
                params: params,
                requestEnd: requestEnd,
                requestStart: requestStart
            } );

            viewModel.set( "components", dataSource );

            return false;

        },

    } );

    pub.open = function( item ) {

        viewModel.set( "currentItem", item );

        viewModel.showComponentsList();

        var onDone = function() {
            NM.util.openModal( $( "#component-list-modal" ) );
        };

    };

    pub.init = function() {

        kendo.bind( fields.listRoot, viewModel );

    };

    return pub;

}() );