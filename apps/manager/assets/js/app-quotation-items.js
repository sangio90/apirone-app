AP.namespace( "quotation" );

AP.quotation.fields = {
    itemsRoot: $( "#quotation-items-root" )
};

$( document ).ready( function() {
    if ( AP.quotation.fields.itemsRoot.length ) {
        AP.quotation.items.init();
    }
} );


AP.quotation.items = ( function() {
    var pub = {};
    var signageApp = AP.signage.modal;

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

            filterDataSource.filter( filters );

            viewModel.set( "rows", filterDataSource );

            return false;
        },

        new: function( ) {
            window.location.href = "/manager/quotations/new";
        },

        addSignage: function( ) {
            signageApp.new();
        }
    } );

    pub.init = function() {
        console.log( "quotation.items:init" );
        kendo.bind( AP.quotation.fields.itemsRoot, viewModel );
    };

    return pub;
}() );