AP.lineCategory = AP.lineCategory || {};

AP.lineCategory.fields = {
    listRoot: $( "#line-category-list-root" ),
    searchForm: $( "#line-category-search-form" ),
    cloneModal: $( "#line-category-clone-modal" ),
    cloneForm: $( "#line-category-clone-form" )
};

$( document ).ready( function() {
    if ( AP.lineCategory.fields.listRoot.length ) {
        AP.lineCategory.list.init();
    }
} );

AP.lineCategory.list = ( function() {
    var pub = {};
    var fields = AP.lineCategory.fields;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/lines/categories/" + AP.page.categoryId } )
    };

    var fields = AP.lineCategory.fields;

    var viewModel = kendo.observable( {
        rows: dataSources.items,
        lines: dataSources.items,

        cloneForm: {
            fromLines: [],
            toLines: [],
            data: {
                categoryId: AP.page.categoryId,
                fromLineId: "",
                toLineId: ""
            }
        },

        search: function( event ) {
            var thisForm = fields.searchForm;

            var params = thisForm.serializeJSON();

            params.categoryId = fields.listRoot.find( "[name=categoryId]" ).val();

            viewModel.get( "rows" ).read( params );

            return false;
        },

        showCloneModal: function( event ) {

            var fromLines = viewModel.get( "lines" ).data().toJSON();
            var toLines = viewModel.get( "lines" ).data().toJSON();

            toLines.unshift( { id: "", name: "-- seleziona la linea di destinazione" } );

            viewModel.set( "cloneForm.fromLines", fromLines );
            viewModel.set( "cloneForm.toLines", toLines );

            viewModel.set( "cloneForm.data.fromLineId", event.data.id );
            viewModel.set( "cloneForm.data.categoryId", AP.page.categoryId );

            NM.util.openModal( fields.cloneModal );
            return false;
        },

        clone: function( event ) {

            var thisForm = fields.cloneForm;

            var status = thisForm.find( ".status" );

            if ( thisForm.valid() ) {

                status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/lines/clone",
                    data: JSON.stringify( viewModel.get( "cloneForm.data" ) ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
                                NM.util.autoHideMessage( status, "<span class='green'>Dati salvati nella linea</span>" );

                                setTimeout( () =>
                                    $( fields.cloneModal ).modal( "hide" ), 1000
                                );

                            }
                        },
                    },
                } );
            }
            return false;
        },

        change: function( event ) {
            var select = $( event.currentTarget );
            var categoryId = select.val();
            var category = select.find( "option:selected" ).data( "name" );
            var title = "Linee per < " + category + " >";

            // change url and title
            window.history.pushState( {}, "", categoryId );
            document.title = title;

            fields.listRoot.find( "h2" ).text( title );

            viewModel.set( "rows", NM.kendo.dataSource( { url: "/manager/ajax/lines/categories/" + categoryId } ) );

            return false;
        },

        products: function( event ) {
            var id = event.data.id;
            var categoryId = fields.listRoot.find( "[name=categoryId]" ).val();

            window.open( "/manager/lines/" + id + "/categories/" + categoryId + "/products", "_blank" ).focus();

            return false;
        },

        attributes: function( event ) {
            /*
                note: redirect in controller to first product
            */


            var id = event.data.id;
            var categoryId = fields.listRoot.find( "[name=categoryId]" ).val();

            console.log( "attributes clicked", id, categoryId );


            window.open( "/manager/lines/" + id + "/categories/" + categoryId + "/attributes", "_blank" ).focus();

            // window.open( "/manager/lines/" + id + "/attributes", "_blank" ).focus();

            return false;
        },
    } );

    pub.init = function() {

        kendo.bind( AP.lineCategory.fields.listRoot, viewModel );

        var thisForm = fields.cloneForm;

        thisForm.validate( {
            rules: {
                fromLineId: {
                    required: true
                },
                toLineId: {
                    required: true,
                    notEqualTo: "#fromLineId"
                },
            },
            messages: {
                fromLineId: {
                    required: "Seleziona la linea di partenza.",
                },
                toLineId: {
                    required: "Seleziona la linea di destinazione.",
                    notEqualTo: "Le linee non possono essere le stesse."
                },
            },
        } );

    };

    return pub;
}() );
