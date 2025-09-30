AP.price = AP.price || {};
AP.fields.price = AP.fields.price || {};

AP.fields.price = {
    manageRoot: $( "#price-manage-root" ),
    manageForm: $( "#price-manage-search-form" ),
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

        search: function( event ) {

            var thisForm = AP.fields.price.searchListForm;

            console.log( "searchListForm", thisForm );

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;

        },

        save: function( event ) {

            var manageForm = AP.fields.price.manageForm;
            var status = manageForm.find( ".status" );

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            // if ( manageForm.valid() ) {
            if ( true ) {
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/prices/reassign",
                    data: JSON.stringify( manageForm.serializeJSON() ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
                                // NM.util.autoHideMessage(status, "<span class='green'>Prezi salvati</span>");
                                AP.widget.notify( "success", "Prezzi salvati con successo" );
                                status.html( "" );
                            }
                        },
                    },
                } );
            }

            return false;

        },

    } );

    pub.init = function() {

        kendo.bind( AP.fields.price.manageRoot, viewModel );

    };

    return pub;
}() );
