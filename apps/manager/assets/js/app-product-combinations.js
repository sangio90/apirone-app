AP.product = AP.product || {};
AP.fields.combination = AP.fields.combination || {};

AP.fields.combination = {
    listRoot: $( "#product-combinations-root" ),
    listForm: $( "#product-combinations-form" ),
    imagesModal: $( "#product-images-list-modal" ),
    searchForm: $( "#product-combinations-search-form" ),
};

$( document ).ready( function() {
    if ( AP.fields.combination.listRoot.length ) {
        AP.product.combination.init();
    }
} );

AP.product.combination = ( function() {
    var pub = {};

    var fields = AP.fields.combination;
    var fileApp = AP.file.modal;

    var dataSources = {
        items: NM.kendo.dataSource( {
            url: "/manager/ajax/products/" + AP.page.productId + "/combinations",
        } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        search: function( event ) {
            var thisForm = fields.searchForm;
            var params = thisForm.serializeJSON();
            var filters = [];

            var dataSource = viewModel.get( "rows" );

            var filterDataSource = new kendo.data.DataSource( {
                data: dataSource.data().toJSON(),
            } );

            if ( params.statusId.length ) {
                filters.push( {
                    field: "status.id",
                    operator: "equal",
                    value: params.statusId,
                } );
            }

            if ( params.str.length ) {
                filters.push( {
                    field: "name",
                    operator: "contains",
                    value: params.str,
                } );
            }

            filterDataSource.filter( filters );

            viewModel.set( "rows", filterDataSource );

            return false;
        },

        calculate: function( event ) {
            var id = event.data.id;
            var thisList = AP.fields.combination.listRoot;

            var status = thisList.find( ".status" );
            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/products/" + AP.page.productId + "/combinations/calculate",
                callback: {
                    done: function( xhr ) {
                        AP.widget.notify(
                            "success",
                            "Combinazioni generate con successo.",
                            "Ok!",
                        );
                        viewModel.rows.read();
                    },
                },
            } );
            return false;
        },

        delete: function( event ) {
            var checks = fields.listForm.find( "[name=selected]:checked" );

            if ( checks.length ) {
                var values = [];

                checks.each( function() {
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/products/" + AP.page.productId + "/combinations",
                    data: ids,
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.data.payload.hasOwnProperty( "errors" ) ) {
                                AP.widget.notify(
                                    "error",
                                    "Non riesco a cancellare tutte le combinazioni",
                                );
                            } else {
                                AP.widget.notify(
                                    "success",
                                    "Cancellazione avvenuta con successo",
                                );
                            }

                            viewModel.rows.read();
                        },
                    },
                } );
            } else {
                AP.widget.notify( "warning", "Seleziona almeno una combinazione" );
            }
        },

        openImagesList: function( event ) {

            var element = $( event.currentTarget );
            var id = event.data.id;

            var value = {
                type: "combination",
                id: id,
                name: id
            };

            fileApp.open( value );

            return false;
        },
    } );

    pub.init = function() {
        kendo.bind( AP.fields.combination.listRoot, viewModel );
    };

    return pub;
} () );
