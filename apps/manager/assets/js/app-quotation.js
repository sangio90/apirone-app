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

            filterDataSource.filter( filters );

            viewModel.set( "rows", filterDataSource );

            return false;
        },

        new: function( ) {
            window.location.href = "/manager/quotations/new";
        },
    } );

    pub.init = function() {
        kendo.bind( AP.quotation.fields.listRoot, viewModel );

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
    };

    return pub;
}() );