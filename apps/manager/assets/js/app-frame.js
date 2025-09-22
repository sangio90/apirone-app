AP.namespace( "frame" );

AP.frame.fields = {
    listRoot: $( "#frame-list-root" ),
    listTable: $( "#frame-list-table" ),
    searchForm: $( "#frame-search-form" ),
    detailRoot: $( "#frame-detail-modal" ),
    detailForm: $( "#frame-detail-form" ),
    cellsContainer: $( "#frame-cells-container" ),
    cellsTable: $( "#frame-cells-table" ),
    addRowBtn: $( "#add-row-btn" ),
    removeRowBtn: $( "#remove-row-btn" ),
    addColBtn: $( "#add-col-btn" ),
    removeColBtn: $( "#remove-col-btn" ),
    saveGridBtn: $( "#save-grid-btn" )
};

$( document ).ready( function() {
    AP.frame.list.init();
    AP.frame.modal.init();
} );

AP.frame.list = ( function() {

    var pub = {};
    var fields = AP.frame.fields;

    var onSave = function() {
        viewModel.get( "row" ).read;
    };

    var dataSource = NM.kendo.dataSource( { url: "/manager/ajax/frames" } );

    var viewModel = kendo.observable( {
        rows: dataSource,

        search: function() {
            var filter = {
                code: $( "#search-code" ).val(),
                orientationId: $( "#search-orientation-id" ).val()
            };

            this.rows.transport.options.read.data = {
                filter: filter
            };

            this.rows.read();
        },

        resetSearch: function() {
            $( "#search-code" ).val( "" );
            $( "#search-orientation-id" ).val( "" );
            this.search();
        },

        new: function() {

            console.log( "onSave", onSave );

            AP.frame.modal.new( onSave );
        },

        showDetail: function( e ) {
            var frameId = $( e.currentTarget ).data( "frame-id" );
            AP.frame.modal.open( frameId );
        }
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
        /*
            from array of array:
                [ //col
                    [{},{}] //row
                    [{},{}]
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
        gridRows: 3,
        gridCols: 3,
        cellsMatrix: [],
        loading: false,
        callbacks: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined
        },

        reset: function() {
            this.set( "frame", {
                frameId: "",
                frame: "",
                code: "",
                orientation: {
                    id: ""
                },
                cellOrientation: {
                    id: ""
                },
                cells: []
            } );
            this.set( "gridRows", 3 );
            this.set( "gridCols", 3 );
            this.updateCellsMatrix();
        },

        addRow: function() {
            this.set( "gridRows", this.get( "gridRows" ) + 1 );
            this.updateCellsMatrix();
        },

        removeRow: function() {
            if ( this.get( "gridRows" ) > 1 ) {
                this.set( "gridRows", this.get( "gridRows" ) - 1 );
                this.updateCellsMatrix();
            }
        },

        addCol: function() {
            this.set( "gridCols", this.get( "gridCols" ) + 1 );
            this.updateCellsMatrix();
        },

        removeCol: function() {
            if ( this.get( "gridCols" ) > 1 ) {
                this.set( "gridCols", this.get( "gridCols" ) - 1 );
                this.updateCellsMatrix();
            }
        },

        updateCellsMatrix: function() {
            var rows = this.get( "gridRows" );
            var cols = this.get( "gridCols" );
            var cells = this.get( "frame.cells" ) || [];
            var matrix = [];

            // Inizializza matrice vuota con rowIndex
            for ( var i = 0; i < rows; i++ ) {
                matrix[i] = [];
                for ( var j = 0; j < cols; j++ ) {
                    matrix[i][j] = { value: "_", row: i, col: j }; // aggiungi rowIndex e colIndex
                }
            }

            // Popola la matrice con i valori esistenti
            cells.forEach( function( cell ) {
                if ( cell.row < rows && cell.col < cols ) {
                    matrix[cell.row][cell.col] = {
                        value: cell.value,
                        row: cell.row,
                        col: cell.col
                    };
                }
            } );

            console.log( "matrix", matrix );

            this.set( "cellsMatrix", matrix );
        },

        save: function() {

            var thisForm = fields.detailForm;
            var status = $( "footer .status" );

            if ( thisForm.valid() ) {

                status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

                var self = this;
                var frame = this.get( "detailForm.data" );
                frame.cells = cellsToArray();
                console.log( "cells", frame.cells );

                console.log( "frame.cells", frame.cells );

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/frames",
                    data: JSON.stringify( frame ),
                    callback: {
                        done: function( xhr ) {

                            status.html( "" );

                            AP.widget.notify( "success", "Armatura salvata con successo", "Ok" );

                            setTimeout( () => {
                                $( "#account-detail-modal" ).modal( "hide" );
                                AP.util.fireCallback( "onSave", viewModel.get( "callbacks" ) );
                            }, 1000 );

                        },
                    },
                } );

            }


        },

        load: function( frameId ) {
            var self = this;

            if ( !frameId ) {
                this.reset();
                return;
            }

            this.set( "loading", true );

            NM.util.ajax( {
                method: "GET",
                url: "/ajax/frames/" + frameId,
                callback: {
                    done: function( xhr ) {
                        if ( xhr.success ) {
                            self.set( "frame", xhr.data );

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
                            } else {
                                self.set( "gridRows", 3 );
                                self.set( "gridCols", 3 );
                            }

                            self.updateCellsMatrix();
                        } else {
                            NM.util.showError( xhr.message || "Armatura non trovata" );
                        }
                        self.set( "loading", false );
                    },
                },
            } );

        },

    } );

    pub.edit = function( frameId ) {
        viewModel.load( frameId );
        AP.frame.fields.detailRoot.modal( "show" );
    };

    pub.new = function( onCreate ) {

        console.log( "onCreate", onCreate );

        if( onCreate ) {
            viewModel.set( "callbacks.onCreate", onCreate );
        }

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

        console.log( "AP.frame.fields.detailRoot", AP.frame.fields.detailRoot );

        kendo.bind( AP.frame.fields.detailRoot, viewModel );

        AP.frame.fields.detailForm.on( "submit", function( e ) {
            e.preventDefault();
            viewModel.save();
        } );

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

                        console.log( "gridExists", viewModel.get( "cellsMatrix" ).length );

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
