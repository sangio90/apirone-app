AP.quotation = AP.quotation || {};

AP.quotation.fields = {
    listRoot: $( "#quotation-list-exported-root" ),
    searchForm: $( "#quotation-exported-search-form" ),
    modalRoot: $( "#modal-root" )
};

$( document ).ready( function() {
    if ( AP.quotation.fields.listRoot.length ) {
        console.log( "export" );
        AP.quotation.list.init();
    }
} );


AP.quotation.list = ( function() {
    var pub = {};

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/quotations-exported" } ),
    };

    var fields = AP.quotation.fields;

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        getDate: function( event ) {
            return NM.kendo.formatISODate( event.exportDate, "date-only" );
        },

        search: function( event ) {
            var thisForm = fields.searchForm;
            var params = thisForm.serializeJSON();

            var filters = [];

            var dataSource = viewModel.get( "rows" );

            var filterDataSource = new kendo.data.DataSource( {
                data: dataSource.data().toJSON(),
            } );

            if ( params.str.length ) {
                filters.push( {
                    field: "company",
                    operator: "contains",
                    value: params.str,
                } );
            }

            filterDataSource.filter( filters );

            viewModel.set( "rows", filterDataSource );

            return false;
        },

        edit: function( e ) {
            e.preventDefault();

            let data = {
                "code": "",
                "quotationSerial": "",
                "quotationCode": "",
            };

            const row = $( e.currentTarget.parentElement.parentElement );

            if ( row.length > 0 ) {
                data = {
                    "code": row.find( ".company" )[0].innerHTML,
                    "quotationSerial": row.find( ".quotationSerial" )[0].innerHTML,
                    "quotationCode": row.find( ".quotationCode" )[0].innerHTML
                };
            }

            if ( AP.quotation.fields.modalRoot.length ) {
                AP.quotation.modal.methods().resetForm();
                AP.quotation.modal.init( data );
            }
            NM.util.openModal( AP.quotation.fields.modalRoot );
        },

        delete: function( e ) {
            e.preventDefault();

            const row = $( e.currentTarget.parentElement.parentElement );
            const quotationSerial = row.find( ".quotationSerial" )[0].innerHTML;

            bootbox.confirm( {
                title: "Cancellazione Preventivo Esportato",
                message: "Sei sicuro di voler cancellare questo preventivo dalla tabella di esportazione?",
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
                callback: async function( result ) {
                    if ( result ) {
                        await NM.util.ajax( {
                            method: "DELETE",
                            url: "/manager/ajax/quotations-exported/" + quotationSerial,
                            callback: {
                                done: function( xhr ) {
                                    if( xhr.status == "ERRORE" ) {
                                        AP.loading.hide();
                                        AP.widget.notify( "error", "Errore durante la cancellazione della riga." );
                                    }
                                    if ( xhr.status == "SUCCESS" ) {
                                        window.location.reload();
                                    }
                                }
                            }
                        } );
                    }
                }
            } );

            return false;
        },

        deleteSelected: async function( e ) {
            e.preventDefault();

            var checks = $( "#quotation-exported-grid-form input[name=selected]:checked" );
            if ( !checks.length ) {
                return false;
            }

            var selected = [];

            for ( var check of checks ) {
                check = $( check );
                selected.push( check.val() );
            }

            bootbox.confirm( {
                title: "Cancellazione Multipla Preventivi Esportati",
                message: "Sei sicuro di voler cancellare i preventivi selezionati dalla tabella di esportazione?",
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
                callback: async function( result ) {
                    if ( result ) {
                        await NM.util.ajax( {
                            method: "POST",
                            url: "/manager/ajax/quotations-exported",
                            data: { selected },
                            callback: {
                                done: function( xhr ) {
                                    if( xhr.status == "ERRORE" ) {
                                        AP.loading.hide();
                                        AP.widget.notify( "error", "Errore durante la cancellazione multipla." );
                                    }
                                    if ( xhr.status == "SUCCESS" ) {
                                        window.location.reload();
                                    }
                                }
                            }
                        } );
                    }
                }
            } );

            return false;
        }
    } );

    pub.init = function() {
        kendo.bind( AP.quotation.fields.listRoot, viewModel );

        viewModel.get( "rows" ).fetch( function() {
            viewModel.search();
        } );
    };

    return pub;
}() );

AP.quotation.modal = ( function() {
    var pub = {};

    var fields = AP.quotation.fields;

    var defaultDetailForm = {
        data: {
            code: "",
            quotationSerial: "",
            quotationCode: "",
            items: new kendo.data.DataSource(),
        }
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,

        resetForm: function() {
            viewModel.set( "detailForm", defaultDetailForm );
        },


        delete: async function( e ) {
            e.preventDefault();

            const row = $( e.currentTarget.parentElement.parentElement );
            const rowNumber = row.find( ".rowNumber" )[0].innerHTML;

            bootbox.confirm( {
                title: "Cancellazione Elemento dal Preventivo Esportato",
                message: "Sei sicuro di voler cancellare questo Articolo dal Preventivo Esportato?",
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
                callback: async function( result ) {
                    if ( result ) {
                        await NM.util.ajax( {
                            method: "DELETE",
                            url: "/manager/ajax/quotation-exported-rows/?key=" + viewModel.get( "detailForm.quotationSerial" ) + "&rowNumber=" + rowNumber,
                            callback: {
                                done: function( xhr ) {
                                    if( xhr.status == "ERRORE" ) {
                                        AP.loading.hide();
                                        AP.widget.notify( "error", "Errore durante la cancellazione della riga." );
                                    }
                                    if ( xhr.status == "SUCCESS" ) {
                                        window.location.reload();
                                    }
                                }
                            }
                        } );
                    }
                }
            } );

            return false;
        }
    } );

    pub.init = async function( data ) {
        AP.loading.show();
        kendo.bind( fields.modalRoot, viewModel );
        viewModel.set( "detailForm.code", data.code );
        viewModel.set( "detailForm.quotationSerial", data.quotationSerial );
        viewModel.set( "detailForm.quotationCode", data.quotationCode );
        $( "#modalTitle" ).text( "Articolli del Preventivo " + data.quotationCode + " per " + data.code );

        await NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations-exported/" + viewModel.get( "detailForm.quotationSerial" ),
            callback: {
                done: function( xhr ) {
                    if( xhr.status == "ERRORE" ) {
                        AP.loading.hide();
                        AP.widget.notify( "error", "Errore nel recupero delle righe." );
                    }
                    if ( xhr.status == "SUCCESS" ) {
                        viewModel.set( "detailForm.items", xhr.data );
                        AP.loading.hide();
                    }
                }
            }
        } );
    };

    pub.methods = function( options ) {
        return viewModel;
    };
    return pub;
} () );