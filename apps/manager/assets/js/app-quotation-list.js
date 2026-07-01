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
        dataSource: dataSources,
        rows: dataSources.items,

        getCreatedAt: function( event ) {
            return NM.kendo.formatISODate( event.createdAt );
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

            AP.loading.hide()

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

		destroy: function( e ) {
			e.preventDefault();
            const id = e.data.id;
			if ( !id || id == "" ) {
				return false;
			}

            bootbox.confirm( {
                title: "Conferma cancellazione preventivo",
                message: "Sei sicuro di voler eliminare questo preventivo? Tutte le zone, gli articoli e i prezzi calcolati verranno persi definivamente.",
                buttons: {
                    confirm: {
                        label: "Si, confermo",
                        className: "btn-primary",
                    },
                    cancel: {
                        label: "No, chiudi",
                        className: "btn-danger",
                    },
                },
                callback: function( result ) {
                    if ( result ) {
                        NM.util.ajax({
                        method: "DELETE",
                        url: "/manager/ajax/quotations/" + id,
                        callback: {
                            done: async function (xhr) {
                                AP.widget.notify( "success", "Preventivo eliminato con successo." );
                                AP.loading.show();
                                await viewModel.dataSource.items.read()
                                viewModel.rows = viewModel.dataSource.items;
                                viewModel.search();
                                AP.loading.hide();
                            }
                        }
                    });
                    } 
                },
            } );
		},

        new: function( ) {
            window.location.href = "/manager/quotations/new";
        },
    } );

    pub.init = function() {

        AP.loading.show()

        kendo.bind( AP.quotation.fields.listRoot, viewModel );

        viewModel.get( "rows" ).fetch( function() {
            AP.loading.hide();
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