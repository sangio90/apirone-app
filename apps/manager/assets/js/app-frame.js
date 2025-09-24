AP.namespace( "frame" );

AP.frame.fields = {
    listRoot: $( "#frame-list-root" ),
    searchForm: $( "#frame-grid-search-form" ),
    detailRoot: $( "#frame-detail-modal" ),
    detailForm: $( "#frame-detail-form" ),
};

$( document ).ready( function() {
    AP.frame.list.init();
    AP.frame.modal.init();
} );

AP.frame.list = ( function() {

    var pub = {};
    var fields = AP.frame.fields;

    var onSave = function() {
        viewModel.get( "rows" ).read();
    };

    var dataSource = NM.kendo.dataSource( { url: "/manager/ajax/frames" } );

    var viewModel = kendo.observable( {
        rows: dataSource,

        search: function() {

            var thisForm = fields.searchForm;
            var params = thisForm.serializeJSON();

            this.rows.read( params );

            return false;

        },

        delete: function() {
            var checks = $( "#frame-grid-form" ).find( "[name=selected]:checked" );

            if ( checks.length ) {
                var values = [];

                checks.each( function() {
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/frames",
                    data: ids,
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.data.payload.hasOwnProperty( "errors" ) ) {
                                AP.widget.notify( "error", "Non riesco a cancellare tutti i frame" );
                            } else {
                                AP.widget.notify( "success", "Cancellazione avvenuta con successo" );
                            }

                            viewModel.rows.read();
                        },
                    },
                } );
            } else {
                AP.widget.notify( "warning", "Seleziona almeno una armatura" );
            }
        },

        new: function() {

            AP.frame.modal.new( onSave );
        },

        edit: function( event ) {

            AP.frame.modal.edit( event.data.id, onSave );

            return false;
        },

    } );

    pub.init = function() {
        if ( !AP.frame.fields.listRoot.length ) { return; }

        kendo.bind( AP.frame.fields.listRoot, viewModel );

    };

    return pub;

}() );

AP.frame.modal = ( function() {

    var pub = {};
    var fields = AP.frame.fields;

    var defaultForm = {
        title: "Carica armatura",
        data: {
            id: "",
            name: "",
            code: "",
            orientation: {
                id: "HOR"
            },
            cellOrientation: {
                id: "HOR"
            },
            status: {
                id: "ACT"
            },
            cells: []
        }
    };

    var cellsToArray = function() {
        /* INFO:
            from array of array:
                [ //col
                    cells: [{},{}] //row
                    cells: [{},{}]
                ]
            to plain array
        */
        var matrix = viewModel.get( "cellsMatrix" );

        var cells = [];

        for ( var i = 0; i < matrix.length; i++ ) {
            for ( var j = 0; j < matrix[i].length; j++ ) {
                cells.push( {
                    row: i,
                    col: j,
                    value: matrix[i][j].value
                } );
            }
        }

        return cells;
    };

    var viewModel = kendo.observable( {
        detailForm: defaultForm,
        orientations: AP.page.orientations,
        statuses: AP.page.statuses,
        types: AP.page.types,

        gridRows: 3,
        gridCols: 3,

        // cellsMatrix: new kendo.data.ObservableArray( [] ),
        cellsMatrix: [],
        loading: false,
        callbacks: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined
        },

        addBaseGrid: function() {
            // this.set( "gridRows", this.get( "gridRows" ) + 1 );
            this.updateCellsMatrix();
        },

        /*
        addRow: function() {
            this.set( "gridRows", this.get( "gridRows" ) + 1 );
            this.updateCellsMatrix();
        },
        */

        addRowAfter: function( rowIdx ) {
            var matrix = this.get( "cellsMatrix" );
            var cols = matrix[0].cells.length;
            var newRow = { cells: [] };
            for ( var j = 0; j < cols; j++ ) {
                newRow.cells.push( { value: "_", row: rowIdx + 1, col: j } );
            }
            matrix.splice( rowIdx + 1, 0, newRow );

            // Aggiorna gli indici delle righe successive
            for ( var i = rowIdx + 2; i < matrix.length; i++ ) {
                for ( var j = 0; j < cols; j++ ) {
                    matrix[i].cells[j].row = i;
                }
            }
            this.set( "cellsMatrix", matrix );
        },

        deleteRow: function( rowIdx ) {
            var matrix = this.get( "cellsMatrix" );
            if ( matrix.length > 1 ) {
                matrix.splice( rowIdx, 1 );
                // Aggiorna gli indici delle righe successive
                for ( var i = rowIdx; i < matrix.length; i++ ) {
                    for ( var j = 0; j < matrix[i].cells.length; j++ ) {
                        matrix[i].cells[j].row = i;
                    }
                }
                this.set( "cellsMatrix", matrix );
            }
        },

        addCol: function( event ) {
            var colIdx = event.data.col;
            var matrix = this.get( "cellsMatrix" );

            for ( var i = 0; i < matrix.length; i++ ) {
                matrix[i].cells.splice( colIdx + 1, 0, { value: "_", row: i, col: colIdx + 1 } );
                // Aggiorna gli indici delle colonne successive
                for ( var j = colIdx + 2; j < matrix[i].cells.length; j++ ) {
                    matrix[i].cells[j].col = j;
                }
            }
            this.set( "cellsMatrix", matrix );
        },

        updateCellsMatrix: function() {
            var rows = this.get( "gridRows" );
            var cols = this.get( "gridCols" );
            var cells = this.get( "detailForm.data.cells" ) || [];
            var matrix = [];

            // Crea la matrice vuota come array di oggetti { cells: [...] }
            for ( var i = 0; i < rows; i++ ) {
                var row = { cells: [] };
                for ( var j = 0; j < cols; j++ ) {
                    row.cells.push( { value: "_", row: i, col: j } );
                }
                matrix.push( row );
            }

            // Popola la matrice con i valori esistenti
            cells.forEach( function( cell ) {
                if ( cell.row < rows && cell.col < cols ) {
                    matrix[cell.row].cells[cell.col].value = cell.value;
                }
            } );

            console.log( "matrix", matrix );

            this.set( "cellsMatrix", matrix );
        },

        load: function( frameId ) {
            var self = this;

            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/frames/" + frameId,
                callback: {
                    done: function( xhr ) {

                        self.set( "detailForm.data", xhr.data );
                        self.set( "detailForm.data.cells", xhr.data.cells );
                        self.set( "detailForm.title", "Modifica armatura < " + xhr.data.name + " >" );

                        // Calcola il numero di righe e colonne necessario
                        var maxRow = 0;
                        var maxCol = 0;

                        if ( xhr.data.cells && xhr.data.cells.length ) {

                            xhr.data.cells.forEach( function( cell ) {
                                maxRow = Math.max( maxRow, cell.row );
                                maxCol = Math.max( maxCol, cell.col );
                            } );

                            self.set( "gridRows", maxRow + 1 );
                            self.set( "gridCols", maxCol + 1 );

                        }

                        // self.updateCellsMatrix();

                    },
                },
            } );

        },

        save: function() {

            var thisForm = fields.detailForm;
            var status = $( "footer .status" );

            if ( thisForm.valid() ) {

                status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

                var self = this;
                var frame = this.get( "detailForm.data" );
                frame.cells = cellsToArray();

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/frames",
                    data: JSON.stringify( frame ),
                    callback: {
                        done: function( xhr ) {

                            status.html( "" );

                            AP.widget.notify( "success", "Armatura salvata con successo", "Ok" );

                            var cb = self.get( "detailForm.data.id" ).length ? "onUpdate" : "onCreate";

                            console.log( "save:cb", cb );
                            console.log( "save:id", self.get( "detailForm.data.id" ) );

                            setTimeout( () => {
                                $( "#frame-detail-modal" ).modal( "hide" );
                                AP.util.fireCallback( cb, viewModel.get( "callbacks" ) );
                            }, 1000 );

                        },
                    },
                } );

            }


        },

    } );

    pub.edit = function( frameId, onUpdate ) {

        if( onUpdate ) {
            viewModel.set( "callbacks.onUpdate", onUpdate );
        }

        viewModel.load( frameId );

        AP.frame.fields.detailRoot.modal( "show" );
    };

    pub.new = function( onCreate ) {

        if( onCreate ) {
            viewModel.set( "callbacks.onCreate", onCreate );
        }

        viewModel.set( "detailForm", defaultForm );
        viewModel.set( "cellsMatrix", [] );

        AP.frame.fields.detailRoot.modal( "show" );
    };

    pub.updateCell = function( row, col, value ) {
        // TODO: forse non serve
        var matrix = viewModel.get( "cellsMatrix" );

        if ( matrix[row] && matrix[row][col] !== undefined ) {
            matrix[row][col].value = value;
            viewModel.set( "cellsMatrix", matrix );
        }

    },

    pub.init = function() {
        if ( !AP.frame.fields.detailRoot.length ) { return; }

        kendo.bind( AP.frame.fields.detailRoot, viewModel );

        var detailForm = fields.detailForm;

        detailForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                name: {
                    required: true
                },
                grid: {
                    required: function() {

                        if ( viewModel.get( "cellsMatrix" ).length ) {
                            return false;
                        }

                        return true;

                    }
                },
                code: {
                    required: true,
                    checkCode: true,
                    rangelength: [ 2, 5 ],
                    remote: {
                        url: "/manager/ajax/frames/code-exists",
                        data: {
                            id: function() {
                                return viewModel.get( "detailForm.data.id" );
                            },
                        },
                        dataFilter: function( xhr ) {
                            var json = JSON.parse( xhr );
                            return json.data == false;
                        },
                    },
                },
            },
            messages: {
                name: {
                    required: "Nome richiesto"
                },
                grid: {
                    required:"Inserisci almeno una riga nella griglia",
                },
                code: {
                    required: "Codice richiesto",
                    rangelength: "Sono richiesti 5 caratteri",
                    checkCode: "Solo numeri, lettere, trattino o trattino basso",
                    remote: "Il codice esiste",
                },
            },
        } );

    };

    return pub;

} () );
