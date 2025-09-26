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

    var createCell = function( data ) {

        if ( !data ) {
            var data = {
                width : 0,
                height: 0,
                col   : 0,
                row   : 0,
                id    : NM.util.uuid(),
                type  : { id: "AVAIL", name: "" },
                orientation: { id: "HOR", name: "" }
            };
        }

        var viewModel = new kendo.observable( {
            data: data,

            title: function() {
                return "Modifica cella " + this.get( "data.row" ) + "/" + this.get( "data.col" );
            },

            shortId: function() {
                return this.get( "data.id" ).substr( -5 );
            },

            showContent: function() {
                var typeId = this.get( "data.type.id" );
                return typeId != "COMMAND";
            },

            showDimensions: function() {
                var typeId = this.get( "data.type.id" );
                return typeId == "EMPTY";
            },

            showColCommands: function() {
                var col = this.get( "data.col" );
                var row = this.get( "data.row" );

                if ( col == 0 && row == 0 ) {
                    return false;
                }

                return this.get( "data.row" ) == 0;
            },

            showRowCommands: function() {
                var col = this.get( "data.col" );
                var row = this.get( "data.row" );

                if ( col == 0 && row == 0 ) {
                    return false;
                }

                return col == 0;
            },

            showCellEdit: function() {
                var col = this.get( "data.col" );
                var row = this.get( "data.row" );

                if ( col > 0 && row > 0 ) {
                    return true;
                }

                return false;
            },


            editCell: function( event ) {

                /*
                    NOTE: mvvm does not work fully
                    for this, added:
                        setCellType()
                        saveCell()
                */

                event.data;

                event.data.typesForCell = AP.page.types;
                event.data.orientations = AP.page.orientations;

                console.log( "event.data.typesForCell", event.data.typesForCell );

                console.log( "editCell.data", event );
                console.log( "editCell.data:this", viewModel );
                console.log( "editCell.isObservable:", typeof this.get === "function" );
                console.log( "editCell.costructor", this.constructor.name );

                NM.util.openModal( $( "#frame-cell-modal" ) );

                kendo.bind( $( "#frame-cell-modal" ), viewModel );

                return false;
            },

            setCellType: function( event ) {

                var target = $( event.currentTarget );
                var value = target.val();

                this.set( "data.type.id", value );

                return false;
            },

            saveCell: function( event ) {

                var data = $( "#frame-cell-form" ).serializeJSON();

                this.set( "data.type.id", data.typeId );
                this.set( "data.orientation.id", data.orientationId );
                this.set( "data.height", data.height );
                this.set( "data.width", data.width );

                $( "#frame-cell-modal" ).modal( "close" );

                return false;
            },

            changeOrientation: function() {
                var current = this.get( "data.orientation.id" );

                // Alterna tra "HOR" e "VER"
                var next = ( current === "HOR" ) ? "VER" : "HOR";

                // Imposta il nuovo valore
                this.set( "data.orientation.id", next );
            },

            changeType: function( event ) {
                var currentId = this.get( "data.type.id" );
                var types = AP.page.types;

                var idx = -1;
                for ( var i = 0; i < types.length; i++ ) {
                    if ( types[i].id === currentId ) {
                        idx = i;
                        break;
                    }
                }

                // Calcola l'indice del tipo successivo (ciclico)
                var nextIdx = ( idx + 1 ) % types.length;

                // Imposta il nuovo tipo sulla cella
                this.set( "data.type.id", types[nextIdx].id );
            },


            /*
                css classes
            */

            isFirstLeftCell: function() {
                return this.get( "data.col" ) == 0;
            },

            isCommand: function() {
                return this.get( "data.type.id" ) == "COMMAND";
            },

            isEmpty: function() {
                return this.get( "data.type.id" ) == "EMPTY";
            },

            isAvailable: function() {
                return this.get( "data.type.id" ) == "AVAIL";
            },

            isUnvailable: function() {
                return this.get( "data.type.id" ) == "NOTAV";
            }
        } );

        return viewModel;

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
        var matrix = viewModel.get( "matrix" );

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

    var matrix = new kendo.data.ObservableArray( [] );

    var viewModel = kendo.observable( {
        detailForm: defaultForm,
        orientations: AP.page.orientations,
        statuses: AP.page.statuses,
        types: AP.page.types,

        matrix: matrix,
        loading: false,
        callbacks: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined
        },

        /*
        addBaseGrid: function() {
            // this.set( "gridRows", this.get( "gridRows" ) + 1 );
            this.updateIndexes();
        },
        */

        addBaseGrid: function() {
            var event = {
                data: {
                    data: {
                        col: 0,
                        row: 0
                    }
                }
            };

            this.addCol( event );
            this.addCol( event );

            this.addRow( event );
            this.addRow( event );

            // this.addRow( event );

        },

        addRow: function( event ) {
            // Recupera la matrice dal viewModel
            var matrix = this.get( "matrix" );

            // Calcola il numero di colonne (prende la lunghezza della prima riga)
            var colCount = 0;
            if ( matrix.length && matrix[0].cells ) {
                colCount = matrix[0].cells.length;
            } else {
                // Se la matrice è vuota, imposta almeno una colonna
                colCount = 1;
            }

            // Calcola l'indice della nuova riga (alla fine della matrice)
            var insertIdx = event.data.data.row + 1;

            console.log( "insertIdx", insertIdx );
            console.log( "addRow:event", event );

            // Crea la nuova riga come oggetto con la chiave 'cells'
            var newRow = { cells: new kendo.data.ObservableArray( [] ) };

            // Cicla su tutte le colonne e crea una cella per ciascuna
            for ( var j = 0; j < colCount; j++ ) {
                newRow.cells.splice( insertIdx, 0, createCell() );
            }


            // Aggiungi la nuova riga alla matrice
            // matrix.push( newRow );
            matrix.splice( insertIdx, 0, newRow );

            // Aggiorna la matrice nel viewModel per riflettere la modifica nella UI
            this.set( "matrix", matrix );

            // Aggiorna gli indici di tutte le celle per coerenza
            this.updateIndexes();

        },

        addCol: function( event ) {

            console.log( "addCol" );

            var colIdx = event.data.col;
            var matrix = this.get( "matrix" );

            if ( matrix.length ) {

                matrix.forEach( ( item ) => {
                    item.cells.push( createCell() );
                } );

            } else {
                var matrix = [ {} ];
                matrix[ 0 ].cells = new kendo.data.ObservableArray( [ createCell() ] );
            }

            this.set( "matrix", matrix );

            this.updateIndexes();
        },


        deleteRow: function( event ) {
            // Recupera l'indice della riga da cancellare
            var rowIdx = event.data.data.row;

            // Recupera la matrice dal viewModel
            var matrix = this.get( "matrix" );


            // Se c'è più di una riga, cancella la riga desiderata
            if ( matrix.length > 1 ) {
                matrix.splice( rowIdx, 1 ); // Rimuove la riga con indice rowIdx
            }

            // Aggiorna la matrice nel viewModel
            this.set( "matrix", matrix );

            // Aggiorna gli indici row/col di tutte le celle per coerenza
            this.updateIndexes();
        },


        deleteCol: function( event ) {
            // Recupera l'indice della colonna da cancellare
            var colIdx = event.data.data.col;
            // Recupera la matrice dal viewModel
            var matrix = this.get( "matrix" );

            console.log( "colIdx", colIdx );
            console.log( "colIdx:event", event );

            // Cicla su tutte le righe della matrice
            for ( var i = 0; i < matrix.length; i++ ) {
                // Rimuovi la cella nella posizione colIdx dalla riga corrente
                matrix[i].cells.splice( colIdx, 1 );
            }

            // Aggiorna la matrice nel viewModel
            this.set( "matrix", matrix );

            // Ricalcola gli indici row/col di tutte le celle per coerenza
            this.updateIndexes();
        },

        updateIndexes: function() {

            var matrix = this.get( "matrix" );
            // console.log( "matrix_before", matrix );

            // Cicla su tutte le righe
            for ( var i = 0; i < matrix.length; i++ ) {
                // Cicla su tutte le celle della riga
                for ( var j = 0; j < matrix[i].cells.length; j++ ) {
                    var cell = matrix[i].cells[j];
                    cell.set( "data.row", i );
                    cell.set( "data.col", j );

                    if( j == 0 || i == 0 ) {
                        cell.set( "data.type.id", "COMMAND" );
                    }
                }
                // i.set( "cells", matrix[i].cells );
            }

            // var matrix = this.get( "matrix" );
            // console.log( "matrix_after", matrix );

            // this.set( "matrix", matrix );

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

                        // self.updateIndexes();

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
        viewModel.set( "matrix", [] );

        AP.frame.fields.detailRoot.modal( "show" );
    };

    pub.updateCell = function( row, col, value ) {
        var matrix = viewModel.get( "matrix" );
        if ( matrix[row] && matrix[row].cells[col] !== undefined ) {
            matrix[row].cells[col].value = value;
            viewModel.set( "matrix", matrix );
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

                        if ( viewModel.get( "matrix" ).length ) {
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
