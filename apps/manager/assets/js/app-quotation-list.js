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

    /*
        Filtri della ricerca, inviati al server a ogni read.

        NM.kendo.dataSource cattura questo oggetto nella closure del suo
        parameterMap e lo fonde nei parametri della chiamata: mutandolo qui, la
        pagina successiva e ogni ricarica partono con gli stessi filtri. Va
        quindi svuotato e ripopolato, mai riassegnato.
    */
    var searchParams = {};

    var dataSources = {
        items: NM.kendo.dataSource( {
            url: "/manager/ajax/quotations",
            params: searchParams,
        } ),
    };

    var fields = AP.quotation.fields;

    var viewModel = kendo.observable( {
        dataSource: dataSources,
        rows: dataSources.items,

        getCreatedAt: function( event ) {
            return NM.kendo.formatISODate( event.createdAt );
        },

        /*
            La ricerca va fatta dal server.

            La griglia è paginata lato server (serverPaging, 15 righe per
            pagina), quindi dataSource.data() contiene solo la pagina corrente:
            filtrare quello significherebbe cercare dentro 15 record invece che
            dentro tutti i preventivi. Qui si impostano i parametri e si rilegge
            dalla prima pagina, così il totale e il pager restano quelli veri.
        */
        search: function( event ) {
            var params = fields.searchForm.serializeJSON();
            var dataSource = viewModel.get( "rows" );

            /*
                Ogni filtro va assegnato sempre, anche quando è vuoto.

                Il parameterMap di NM.kendo.dataSource conserva i parametri sul
                transport (`transport.read.data = params`) e a ogni lettura ci
                fonde sopra config.params con Object.assign, che aggiunge ma non
                rimuove: cancellare qui una chiave lascerebbe in vita il valore
                della ricerca precedente, e svuotando il campo si continuerebbe
                a vedere il risultato filtrato. Sovrascriverla con stringa vuota
                la annulla davvero, e paramsFromUrl lato server ignora già i
                parametri vuoti.
            */
            searchParams.str      = params.strSearch || "";
            searchParams.statusId = params.statusId || "";
            searchParams.fromDate = params.fromDate || "";
            searchParams.toDate   = params.toDate || "";

            // "Mostra non attivi" spento: solo i preventivi attivi
            searchParams.active = params.showActive ? "" : 1;

            AP.loading.show();

            dataSource.one( "requestEnd", function() {
                AP.loading.hide();
            } );

            // query() invece di read(): riporta il pager alla prima pagina,
            // altrimenti restando su una pagina alta la ricerca sembrerebbe
            // non dare risultati
            dataSource.query( {
                page: 1,
                pageSize: dataSource.pageSize(),
            } );

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
                        AP.loading.show();
                        NM.util.ajax({
                            method: "DELETE",
                            url: "/manager/ajax/quotations/" + id,
                            callback: {
                                done: function (xhr) {
                                    AP.widget.notify( "success", "Preventivo eliminato con successo." );
                                    // search() rilegge già dal server con i filtri correnti:
                                    // la read() esplicita qui sarebbe una chiamata doppia, e
                                    // il riaggancio di viewModel.rows non serve più da quando
                                    // il dataSource non viene sostituito.
                                    viewModel.search();
                                }
                            }
                        });
                    }
                },
            } );
		},

		clone: function( e ) {
			e.preventDefault();
			const id = e.data.id;
			const num = e.data.quotationNumber;
			if ( !id || id == "" ) {
				return false;
			}

			bootbox.confirm( {
				title: "Duplica preventivo",
				message: "Vuoi duplicare il preventivo <strong>" + num + "</strong>? Verrà creato un nuovo preventivo con tutti i prodotti e le zone.",
				buttons: {
					confirm: {
						label: "Si, duplica",
						className: "btn-primary",
					},
					cancel: {
						label: "Annulla",
						className: "btn-danger",
					},
				},
				callback: function( result ) {
					if ( result ) {
						AP.loading.show();
						NM.util.ajax( {
							method: "POST",
							url: "/manager/ajax/quotations/" + id + "/clone",
							callback: {
								done: function( xhr ) {
									AP.loading.hide();
									if ( xhr.status === "ERROR" ) {
										AP.widget.notify( "error", xhr.data.message );
										return;
									}
									window.location.href = "/manager/quotations/" + xhr.data.payload.id;
								}
							}
						} );
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
            if ( $( "#quotation-status-filter" ).val() ) {
                viewModel.search();
            }
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