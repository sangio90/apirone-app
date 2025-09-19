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
            AP.frame.modal.new();
        },

        addNew: function() {
            AP.frame.modal.open();
        },

        showDetail: function( e ) {
            var frameId = $( e.currentTarget ).data( "frame-id" );
            AP.frame.modal.open( frameId );
        }
    } );

    pub.init = function() {
        if ( !AP.frame.fields.listRoot.length ) { return; }

        kendo.bind( AP.frame.fields.listRoot, viewModel );

        AP.frame.fields.searchForm.on( "submit", function( e ) {
            e.preventDefault();
            viewModel.search();
        } );

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
            cells: []
        }
    };

    var viewModel = kendo.observable( {
        detailForm: defaultForm,
        orientations: AP.page.orientations, // /QUIIIIIIIIIIIIIII
        statuses: AP.page.statuses,
        gridRows: 3,
        gridCols: 3,
        cellsMatrix: [],
        loading: false,

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
                    matrix[i][j] = { value: "_", rowIndex: i, colIndex: j }; // aggiungi rowIndex e colIndex
                }
            }

            // Popola la matrice con i valori esistenti
            cells.forEach( function( cell ) {
                if ( cell.row < rows && cell.col < cols ) {
                    matrix[cell.row][cell.col] = {
                        value: cell.value,
                        rowIndex: cell.row,
                        colIndex: cell.col
                    };
                }
            } );

            this.set( "cellsMatrix", matrix );
        },

        cellsToArray: function() {
            var matrix = this.get( "cellsMatrix" );
            var cells = [];

            for ( var i = 0; i < matrix.length; i++ ) {
                for ( var j = 0; j < matrix[i].length; j++ ) {
                    cells.push( {
                        row: i,
                        col: j,
                        value: matrix[i][j] || "_"
                    } );
                }
            }

            return cells;
        },

        validateForm: function() {
            var frame = this.get( "frame" );

            if ( !frame.code || !frame.frame ) {
                NM.util.showError( "Codice e nome sono obbligatori" );
                return false;
            }

            return true;
        },

        save: function() {
            if ( !this.validateForm() ) { return; }

            var self = this;
            var frame = this.get( "frame" );
            frame.cells = this.cellsToArray();

            this.set( "loading", true );

            NM.util.ajax( {
                method: "GET",
                url: "/ajax/frames",
                callback: {
                    done: function( xhr ) {
                        if ( response.success ) {
                            NM.util.showSuccess( response.message || "Armatura salvata con successo" );
                            self.set( "frame", response.data );

                            // Aggiorna la griglia nella lista
                            if ( AP.frame.list.viewModel.dataSource ) {
                                AP.frame.list.viewModel.dataSource.read();
                            }
                        } else {
                            NM.util.showError( response.message || "Errore durante il salvataggio" );
                        }
                        self.set( "loading", false );

                    },
                },
            } );

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

    pub.new = function( frameId ) {
        AP.frame.fields.detailRoot.modal( "show" );
    };

    pub.editCell = function( row, col, value ) {
        // TODO: forse non serve
        var matrix = viewModel.get( "cellsMatrix" );

        if ( matrix[row] && matrix[row][col] !== undefined ) {
            matrix[row][col] = value;
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
