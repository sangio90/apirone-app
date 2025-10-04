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

    var defaultRows = NM.kendo.dataSource( { url: "/manager/ajax/components" } );

    var viewModel = kendo.observable( {

        rows: defaultRows,

        search: function() {

            var thisForm = $( "#component-grid-search-form" );

            var params = thisForm.serializeJSON();

            var rows = NM.kendo.dataSource( {
                url: "/manager/ajax/components",
                params: params
            } );

            viewModel.set( "rows", rows );

            return false;

        },

        reset: function() {

            var thisForm = $( "#component-grid-search-form" );
            thisForm.trigger( "reset" );

            viewModel.set( "rows", defaultRows );

            return false;

        },

    } );

    pub.init = function() {

        kendo.bind( fields.listRoot, viewModel );

    };

    return pub;

}() );