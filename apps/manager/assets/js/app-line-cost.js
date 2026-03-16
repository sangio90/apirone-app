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
        categories: AP.page.categories,
        category: {
            "id": "",
            "name": ""
        },
        selecteCategory: {
            "id": "",
            "name": ""
        },
        allLines: AP.page.lines,
        lines: new kendo.data.DataSource(),
        line: {
            "id": "",
            "name": ""
        },
        selecteLine: {
            "id": "",
            "name": ""
        },
        allFinishes: AP.page.finishes,
        finishes: new kendo.data.DataSource(),
        finish: {
            "id": "",
            "name": ""
        },
        selecteFinish: {
            "id": "",
            "name": ""
        },

        loadLines: function() {
            this.get('lines').data([]);
            let allLines = this.get("allLines");
            const category = this.get('category')
            const categoryLines = allLines.filter(function(line) {
                return line.categories.filter(cat => cat.id == category.id).length > 0
            })
            this.get('lines').data(categoryLines);
            this.set('line', { "id": "", "name": ""})
            this.set('model', { "id": "", "name": ""})
        },

        loadFinishes: function() {
            this.get('finishes').data([]);
            let allFinishes = this.get("allFinishes");
            const category = this.get('category')
            const categoryFinishes = allFinishes.filter(function(finish) {
                return finish.categories.filter(cat => cat.id == category.id).length > 0
            })
            categoryFinishes.forEach(function(cf) {
                if (cf.texts.find(t => t.lang.id == 'IT' && t.name != '')) {
                    cf.name = cf.texts.find(t => t.lang.id == 'IT' && t.name != '').name
                }
            })
            this.get('finishes').data(categoryFinishes);
            this.set('finish', { "id": "", "name": ""})
        },

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
            if (!parsedData.categoryId || !parsedData.lineId || !parsedData.finishId || !parsedData.cost) {
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
                "categoryId": categoryId,
                "lineId": lineId,
                "finishId": finishId,
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
