AP.quotation = AP.quotation || {};

AP.quotation.fields = {
    listRoot: $( "#quotation-list-root" ),
    searchForm: $( "#quotation-search-form" ),
};

$( document ).ready( function() {
    if ( AP.quotation.fields.listRoot.length ) {
        AP.quotation.list.init();
    }
} );


AP.quotation.list = ( function() {
    var pub = {};

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/quotations" } ),
    };

    var fields = AP.quotation.fields;

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        getDate: function( event ) {
            return NM.kendo.formatISODate( event.quotationDate, "date-only" );
        },

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

            if ( params.strDescription.length ) {
                filters.push( {
                    field: "description",
                    operator: "contains",
                    value: params.strDescription,
                } );
            }

            if ( params.strNumber.length ) {
                filters.push( {
                    field: "quotationNumber",
                    operator: "contains",
                    value: params.strNumber,
                } );
            }

            if ( params.fromDate.length ) {
                var fromDateObject = new Date( params.fromDate );
                filters.push( {
                    field: "quotationDate",
                    operator: "gte",
                    value: fromDateObject,
                } );
            }

            if ( params.toDate.length ) {
                var toDateObject = new Date( params.toDate );
                filters.push( {
                    field: "quotationDate",
                    operator: "lte",
                    value: toDateObject,
                } );
            }

            if ( !params.showActive ) {
                filters.push( {
                    field: "active",
                    operator: "equal",
                    value: 1,
                } );
            }

            filterDataSource.filter( filters );

            viewModel.set( "rows", filterDataSource );

            return false;
        },

        edit: function( e ) {
            e.preventDefault();
            const id = e.data.id;
            if ( !id || id == "" ) {
                return false;
            }
            const url = "/manager/quotations/" + id;
            window.location.href = "/manager/quotations/" + id;
        },

        new: function( ) {
            window.location.href = "/manager/quotations/new";
        },
    } );

    pub.init = function() {

        console.log( "qt:init" );

        kendo.bind( AP.quotation.fields.listRoot, viewModel );

        viewModel.get( "rows" ).fetch( function() {
            viewModel.search();
        } );
        /* TODO: remove this extra code.
        // Formatting by mvvm
        dataSources.items.fetch( function() {
            var rawData = dataSources.items.data();

            rawData.forEach( function( q ) {
                if ( q.quotationDate ) {
                    q.quotationDate = new Date( q.quotationDate );
                }
            } );

            viewModel.set( "rows", new kendo.data.DataSource( {
                data: rawData
            } ) );
        } );
        */
    };

    return pub;
}() );