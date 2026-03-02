AP.namespace( "lineCost" );

Object.assign( AP.lineCost.fields, {
    listRoot: $( "#line-cost-list-root" ),
    detailRoot: $( "#line-cost-modal-root" ),
    detailRoot: $( "#line-cost-grid-form" ),
} );

$( document ).ready( function() {
    if ( AP.lineCost.fields.listRoot.length ) {
        AP.lineCost.list.init();
    }
} );

AP.lineCost.list = ( function() {
    var pub = {};

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/lines_costs" } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        search: function( event ) {
            const data = $('#line-cost-search-form').serializeArray();
            let parsedData = {};
            data.forEach(function (row) {
                parsedData[row.name] = row.value
            })

            viewModel.rows.read( parsedData );

            return false;
        },

        create: function( event ) {
            const data = $('#line-cost-add-form').serializeArray();
            let parsedData = {};
            data.forEach(function (row) {
                parsedData[row.name] = row.value
            })
            parsedData.id = null
            if (!parsedData.category_id || !parsedData.line_id || !parsedData.finish_id || !parsedData.cost) {
                AP.widget.notify( "error", "Compilare tutti i campi." )
                return false
            }

            AP.loading.show()
            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/lines_costs",
                data: JSON.stringify(parsedData),
                callback: {
                    always: function(xhr) {
                        if (xhr.status && xhr.status == 'ERROR') {
                            AP.widget.notify( "error", "Non è possibile assegnare questo costo fisso. " + xhr.message );
                            AP.loading.hide()
                        } else {
                            $('#line-cost-add-form')[0].reset();
                            if (xhr.status && xhr.status == 'SUCCESS') {
                                var modal = bootstrap.Modal.getInstance(
                                    document.getElementById('lineCostAddModal')
                                );
                                modal.hide();
                            }
                            if (xhr.status || xhr.status != 'ERROR') {
                                AP.widget.notify( "success", "Costo Linea/Finitura creato correttamente." );
                                setTimeout( () => {
                                    window.location.reload()
                                }, 500 );
                            }
                        }
                    }
                },
            } );

            return false;
        },

        update: function( event ) {
            AP.loading.show()
            const id = event.data.id
            const categoryId = event.data.category.id
            const lineId = event.data.line.id
            const finishId = event.data.finish.id
            const cost = event.data.cost
            
            if (!cost || cost == 0) {
                AP.widget.notify( "error", "Compilare tutti i campi." )
                return false
            }

            parsedData = {
                "id": id,
                "category_id": categoryId,
                "line_id": lineId,
                "finish_id": finishId,
                "cost": cost
            }

            AP.loading.show()
            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/lines_costs",
                data: JSON.stringify(parsedData),
                callback: {
                    always: function(xhr) {
                        if (xhr.status && xhr.status == 'ERROR') {
                            AP.widget.notify( "error", "Non è possibile aggiornare questo costo fisso. " + xhr.message );
                        }
                        if (xhr.status || xhr.status != 'ERROR') {
                            AP.widget.notify( "success", "Costo Linea/Finitura aggiornato correttamente." );
                        }
                        AP.loading.hide()
                    }
                },
            } );

            return false;
        },

        delete: function( event ) {
            AP.loading.show()
            const id = event.data.id

            parsedData = {
                "id": id
            }

            AP.loading.show()
            NM.util.ajax( {
                method: "DELETE",
                url: "/manager/ajax/lines_costs",
                data: JSON.stringify(parsedData),
                callback: {
                    always: function(xhr) {
                        if (xhr.status && xhr.status == 'ERROR') {
                            AP.widget.notify( "error", "Non è possibile cancellare questo costo fisso. " + xhr.message );
                        }
                        if (xhr.status || xhr.status != 'ERROR') {
                            AP.widget.notify( "success", "Costo Linea/Finitura cancellato correttamente." );
                            setTimeout( () => {
                                window.location.reload()
                            }, 500 );
                        }
                        AP.loading.hide()
                    }
                },
            } );

            return false;
        },

    } );

    pub.init = function() {
        kendo.bind( AP.lineCost.fields.listRoot, viewModel );
    };

    return pub;
} () );
