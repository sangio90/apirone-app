AP.quotationItem = AP.quotationItem || {};

AP.quotationItem.fields = {
    listRoot: $( "#quotation-item-list-exported-root" ),
    searchForm: $( "#quotation-item-exported-search-form" ),
    modalRoot: $( "#modal-root" )
};

$( document ).ready( function() {
    if ( AP.quotationItem.fields.listRoot.length ) {
        AP.quotationItem.list.init();
    }
} );


AP.quotationItem.list = ( function() {
    var pub = {};

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/quotation-items-exported" } ),
    };

    var fields = AP.quotationItem.fields;

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
                    field: "description",
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
                'key': '',
                'code': '',
                'description': '',
            }

            const row = $(e.currentTarget.parentElement.parentElement)

            if (row.length > 0) {
                data = {
                    'key': row.find('.key')[0].innerHTML,
                    'code': row.find('.code')[0].innerHTML,
                    'description': row.find('.description')[0].innerHTML
                }
            }

            if ( AP.quotationItem.fields.modalRoot.length ) {
                AP.quotationItem.modal.methods().resetForm();
                AP.quotationItem.modal.init( data );
            }
            NM.util.openModal( AP.quotationItem.fields.modalRoot );
        },

        delete: function( e ) {
            e.preventDefault();

            const row = $(e.currentTarget.parentElement.parentElement)
            const key = row.find('.key')[0].innerHTML

            bootbox.confirm( {
                title: "Cancellazione Elemento Preventivo Esportato",
                message: "Sei sicuro di voler cancellare questo elemento del preventivo dalla tabella di esportazione?",
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
                            url: "/manager/ajax/quotation-items-exported/" + key,
                            callback: {
                                done: function( xhr ) {
                                    if( xhr.status == "ERRORE" ) {
                                        Loading.hide()
                                        AP.widget.notify( "error", "Errore durante la cancellazione della riga." );
                                    }
                                    if ( xhr.status == "SUCCESS" ) {
                                        window.location.reload()
                                    }
                                }
                            }
                        } );
                    }
                }
            } )

            return false;
        },

        deleteSelected: async function( e ) {
            e.preventDefault();

            var checks = $( "#quotation-item-exported-grid-form input[name=selected]:checked" );
            if ( !checks.length ) {
                return false;
            }

            var selected = [];
            
            for ( var check of checks ) {
                check = $( check );
                selected.push(check.val())
            }

            bootbox.confirm( {
                title: "Cancellazione Multipla Elementi Preventivo Esportato",
                message: "Sei sicuro di voler cancellare gli elementi selezionati del preventivo dalla tabella di esportazione?",
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
                            url: "/manager/ajax/quotation-items-exported",
                            data: { selected },
                            callback: {
                                done: function( xhr ) {
                                    if( xhr.status == "ERRORE" ) {
                                        Loading.hide()
                                        AP.widget.notify( "error", "Errore durante la cancellazione multipla." );
                                    }
                                    if ( xhr.status == "SUCCESS" ) {
                                        window.location.reload()
                                    }
                                }
                            }
                        } );
                    }
                }
            } )

            return false;
        }
    } );

    pub.init = function() {
        kendo.bind( AP.quotationItem.fields.listRoot, viewModel );

        viewModel.get( "rows" ).fetch( function() {
            viewModel.search();
        } );
    };

    return pub;
}() );

AP.quotationItem.modal = ( function() {
    var pub = {};

    var fields = AP.quotationItem.fields;

    var defaultDetailForm = {
        data: {
            key: "",
            code: "",
            description: "",
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

            const row = $(e.currentTarget.parentElement.parentElement)
            const rowNumber = row.find('.rowNumber')[0].innerHTML


            bootbox.confirm( {
                title: "Cancellazione Elemento Distinta Base Esportato",
                message: "Sei sicuro di voler cancellare questo elemento dalla distinta base esportata per il prodotto " + viewModel.get('detailForm.description') +  "?",
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
                            url: "/manager/ajax/quotation-item-exported-rows/?key=" + viewModel.get('detailForm.key') + "&rowNumber=" + rowNumber,
                            callback: {
                                done: function( xhr ) {
                                    if( xhr.status == "ERRORE" ) {
                                        Loading.hide()
                                        AP.widget.notify( "error", "Errore durante la cancellazione della riga." );
                                    }
                                    if ( xhr.status == "SUCCESS" ) {
                                        window.location.reload()
                                    }
                                }
                            }
                        } );
                    }
                }
            } )

            return false;
        }
    } );

    pub.init = async function( data ) {
        Loading.show()
        kendo.bind( fields.modalRoot, viewModel );
        viewModel.set('detailForm.key', data.key)
        viewModel.set('detailForm.code', data.code)
        viewModel.set('detailForm.description', data.description)
        $( "#modalTitle" ).text( "Distinta Base di " + data.description );

        await NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotation-items-exported/" + viewModel.get('detailForm.key'),
            callback: {
                done: function( xhr ) {
                    if( xhr.status == "ERRORE" ) {
                        Loading.hide()
                        AP.widget.notify( "error", "Errore nel recupero delle righe." );
                    }
                    if ( xhr.status == "SUCCESS" ) {
                        viewModel.set( "detailForm.items", xhr.data );
                        Loading.hide()
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