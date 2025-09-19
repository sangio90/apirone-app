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

    var dataSource = NM.kendo.dataSource( { url: "/manager/ajax/audit-entries" } );

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

        addNew: function() {
            AP.frame.modal.open();
        },

        showDetail: function( e ) {
            var frameId = $( e.currentTarget ).data( "frame-id" );
            AP.frame.modal.open( frameId );
        }
    } );

    return {
        // viewModel: viewModel,
        init: function() {
            if ( !AP.frame.fields.listRoot.length ) { return; }

            kendo.bind( AP.frame.fields.listRoot, viewModel );

            AP.frame.fields.searchForm.on( "submit", function( e ) {
                e.preventDefault();
                viewModel.search();
            } );

            // Gestione eventi
            AP.frame.fields.listTable.on( "click", "[data-action='detail']", viewModel.showDetail );

            // Carica i dati
            viewModel.rows.read();
        }
    };
} () );

AP.frame.modal = ( function() {

    var pub = {};
    var fields = AP.frame.field;

    var viewModel = kendo.observable( {
        frame: {
            frameId: "",
            frame: "",
            code: "",
            orientationId: "VER",
            cellOrientationId: "VER",
            cells: []
        },
        gridRows: 3,
        gridCols: 3,
        cellsMatrix: [],
        activeTab: "detail",
        isDirty: false,
        loading: false,

        reset: function() {
            this.set( "frame", {
                frameId: "",
                frame: "",
                code: "",
                orientationId: "VER",
                cellOrientationId: "VER",
                cells: []
            } );
            this.set( "gridRows", 3 );
            this.set( "gridCols", 3 );
            this.set( "activeTab", "detail" );
            this.set( "isDirty", false );
            this.updateCellsMatrix();
        },

        switchTab: function( tab ) {
            this.set( "activeTab", tab );

            if ( tab === "cells" && this.get( "frame.frameId" ) ) {
                this.updateCellsMatrix();
            }
        },

        addRow: function() {
            this.set( "gridRows", this.get( "gridRows" ) + 1 );
            this.set( "isDirty", true );
            this.updateCellsMatrix();
        },

        removeRow: function() {
            if ( this.get( "gridRows" ) > 1 ) {
                this.set( "gridRows", this.get( "gridRows" ) - 1 );
                this.set( "isDirty", true );
                this.updateCellsMatrix();
            }
        },

        addCol: function() {
            this.set( "gridCols", this.get( "gridCols" ) + 1 );
            this.set( "isDirty", true );
            this.updateCellsMatrix();
        },

        removeCol: function() {
            if ( this.get( "gridCols" ) > 1 ) {
                this.set( "gridCols", this.get( "gridCols" ) - 1 );
                this.set( "isDirty", true );
                this.updateCellsMatrix();
            }
        },

        editCell: function( row, col, value ) {
            var matrix = this.get( "cellsMatrix" );
            if ( matrix[row] && matrix[row][col] !== undefined ) {
                matrix[row][col] = value;
                this.set( "cellsMatrix", matrix );
                this.set( "isDirty", true );
            }
        },

        updateCellsMatrix: function() {
            var rows = this.get( "gridRows" );
            var cols = this.get( "gridCols" );
            var cells = this.get( "frame.cells" ) || [];
            var matrix = [];

            // Inizializza matrice vuota
            for ( var i = 0; i < rows; i++ ) {
                matrix[i] = [];
                for ( var j = 0; j < cols; j++ ) {
                    matrix[i][j] = "_"; // Default vuoto
                }
            }

            // Popola la matrice con i valori esistenti
            cells.forEach( function( cell ) {
                if ( cell.row < rows && cell.col < cols ) {
                    matrix[cell.row][cell.col] = cell.value;
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

            $.ajax( {
                url: "/ajax/frames",
                type: "POST",
                contentType: "application/json",
                data: JSON.stringify( frame ),
                success: function( response ) {
                    if ( response.success ) {
                        NM.util.showSuccess( response.message || "Armatura salvata con successo" );
                        self.set( "frame", response.data );
                        self.set( "isDirty", false );

                        // Aggiorna la griglia nella lista
                        if ( AP.frame.list.viewModel.dataSource ) {
                            AP.frame.list.viewModel.dataSource.read();
                        }
                    } else {
                        NM.util.showError( response.message || "Errore durante il salvataggio" );
                    }
                    self.set( "loading", false );
                },
                error: function() {
                    NM.util.showError( "Errore di comunicazione con il server" );
                    self.set( "loading", false );
                }
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


            /*
            $.ajax( {
                url: "/ajax/frames/" + frameId,
                type: "GET",
                dataType: "json",
                success: function( response ) {
                    if ( response.success ) {
                        self.set( "frame", response.data );

                        // Calcola il numero di righe e colonne necessario
                        var maxRow = 0;
                        var maxCol = 0;

                        if ( response.data.cells && response.data.cells.length ) {
                            response.data.cells.forEach( function( cell ) {
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
                        NM.util.showError( response.message || "Armatura non trovata" );
                    }
                    self.set( "loading", false );
                },
                error: function() {
                    NM.util.showError( "Errore di comunicazione con il server" );
                    self.set( "loading", false );
                }
            } );
            */
        },

        codeExists: function() {
            var code = this.get( "frame.code" );
            var frameId = this.get( "frame.frameId" );

            if ( !code ) { return; }

            $.ajax( {
                url: "/ajax/frames/code-exists",
                type: "GET",
                data: {
                    code: code,
                    excludedId: frameId
                },
                success: function( response ) {
                    if ( response.exists ) {
                        NM.util.showWarning( "Il codice è già in uso" );
                    }
                }
            } );
        }
    } );


    pub.edit = function( frameId ) {
        viewModel.load( frameId );
        AP.frame.fields.detailRoot.modal( "show" );
    };

    pub.new = function( frameId ) {
        AP.frame.fields.detailRoot.modal( "show" );
    };

    pub.init = function() {
        if ( !AP.frame.fields.detailRoot.length ) { return; }

        kendo.bind( AP.frame.fields.detailRoot, viewModel );

        AP.frame.fields.detailForm.on( "submit", function( e ) {
            e.preventDefault();
            viewModel.save();
        } );

        var detailForm = fields.modelConfigForm;

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
