AP.namespace( "plate.grid" );
// AP.plate = AP.plate || {};

AP.plate.grid = ( function() {

    // Removed AP.plate context dependency for definition, but using AP namespace for constants storage if needed.
    // Ideally constants should be here.
    AP.plate.constants = { GRID_CELL_DIMENSIONS: { "_": { "height": 180, "width": 45 }, "0": { "height": 105, "width": 52 } } };

    var constants = AP.plate.constants;
    // var fields = AP.plate.fields; // Removed as unused in this scope

    let FREE_CELL_WIDTH;
    let FREE_CELL_HEIGHT;

    const MIN_DISTANCE_BEFORE_DRAGGING = 1;

    const orientation = {
        VERTICAL: "VER",
        HORIZONTAL: "HOR",
        VER: "VERTICAL",
        HOR: "HORIZONTAL",
    };

    const CELL_TYPE = {
        FREE: "_",
        PROHIBITED: "0",
        _: "FREE",
        0: "PROHIBITED",
    };

    const MOVE_DIRECTION = {
        LEFT: 1,
        RIGHT: 2,
        TOP: 4,
        BOTTOM: 8,
    };

    const utils = {
        convertAbsolutePositionToGridPosition( ui, fruitPosition ) {

            let newPositionDirection = 0;
            const deltaLeft = Math.sign( ui.position.left - ui.originalPosition.left );

            if ( deltaLeft > 0 ) {
                newPositionDirection |= MOVE_DIRECTION.RIGHT;
            } else if ( deltaLeft < 0 ) {
                newPositionDirection |= MOVE_DIRECTION.LEFT;
            }

            const deltaTop = Math.sign( ui.position.top - ui.originalPosition.top );
            if ( deltaTop > 0 ) {
                newPositionDirection |= MOVE_DIRECTION.BOTTOM;
            } else if ( deltaTop < 0 ) {
                newPositionDirection |= MOVE_DIRECTION.TOP;
            }

            const fruitsController = AP.plate.modal.fruitsController;
            const grid = fruitsController.plate.grid;

            const result = {
                row: null,
                column: null,
            };

            for ( let row = 0; row < grid.length; row++ ) {
                for ( let column = 0; column < grid[row].length; column++ ) {
                    const cell = grid[row][column];

                    if ( ( newPositionDirection & MOVE_DIRECTION.RIGHT ) == MOVE_DIRECTION.RIGHT ) {
                        if ( cell.left <= fruitPosition.right && fruitPosition.right <= cell.right ) {
                            const fruitWidth = Math.abs( fruitPosition.left - fruitPosition.right );

                            result.column = ( column - ( fruitWidth / FREE_CELL_WIDTH ) ) + 1;
                        }
                    } else if ( ( newPositionDirection & MOVE_DIRECTION.LEFT ) == MOVE_DIRECTION.LEFT ) {
                        if ( cell.left <= fruitPosition.left && fruitPosition.left <= cell.right ) {
                            result.column = column;
                        }
                    } else { // STILL
                        if ( cell.left <= fruitPosition.left && fruitPosition.left <= cell.right ) {
                            result.column = column;
                        }
                    }

                    if ( ( newPositionDirection & MOVE_DIRECTION.BOTTOM ) == MOVE_DIRECTION.BOTTOM ) {
                        if ( cell.top <= fruitPosition.bottom && fruitPosition.bottom <= cell.bottom ) {
                            const fruitHeight = Math.abs( fruitPosition.top - fruitPosition.bottom );

                            result.row = ( row - ( fruitHeight / FREE_CELL_HEIGHT ) ) + 1;
                        }
                    } else if ( ( newPositionDirection & MOVE_DIRECTION.TOP ) == MOVE_DIRECTION.TOP ) {
                        if ( cell.top <= fruitPosition.top && fruitPosition.top <= cell.bottom ) {
                            result.row = row;
                        }
                    } else { // STILL
                        if ( cell.top <= fruitPosition.top && fruitPosition.top <= cell.bottom ) {
                            result.row = row;
                        }
                    }
                }
            }

            // console.log( "convertAbsolutePositionToGridPosition:result", result );

            return result;
        },

        doRectanglesCollide( rectA, rectB ) {
            let result = true;

            if (
                rectA.right <= rectB.left ||
                rectA.left >= rectB.right ||
                rectA.bottom <= rectB.top ||
                rectA.top >= rectB.bottom
            ) {
                result = false;
            }

            return result;
        },

        extractTopLeftPositionFrom( gridPosition ) {
            const result = {
                top: null,
                left: null,
            };

            const fruitsController = AP.plate.modal.fruitsController;
            const grid = fruitsController.plate.grid;

            // console.log( "extractTopLeftPositionFrom:gridPosition", gridPosition );
            // console.log( "extractTopLeftPositionFrom.plate", fruitsController.plate );
            // console.log( "extractTopLeftPositionFrom.plate.grid", fruitsController.plate.grid );

            const cell = grid[gridPosition.row][gridPosition.column];

            // console.log( "cell", cell );
            // console.log( "gridPosition", gridPosition );

            result.top = cell.top;
            result.left = cell.left;

            // console.log( "extractTopLeftPositionFrom:result", result );

            return result;

        },

        findFirstFreePosition( fruit ) {
            const result = {
                row: null,
                column: null,
            };

            // console.log( "AP.plate.modal", AP.plate.modal );

            const fruitsController = AP.plate.modal.fruitsController;
            const grid = fruitsController.plate.grid;

            for ( let y = 0; y < grid.length; y++ ) {

                // debugger;

                // console.log( "grid", grid );
                // console.log( "grid[y]", grid[y] );
                // console.log( "grid[y]y", y );

                const row = grid[y];

                let columnCount = 0;
                for ( let x = 0; x < row.length; x++ ) {
                    const cell = row[ x ];
                    const cellHasFruit = utils.cellHasFruit( y, x );

                    if ( cell.type == CELL_TYPE.PROHIBITED || cellHasFruit ) {
                        columnCount = 0;
                    } else {
                        columnCount++;
                    }

                    // console.log( "grid:columnCount", columnCount );
                    // console.log( "grid:fruit.columnSpan", fruit.columnSpan );

                    if ( columnCount == fruit.columnSpan ) {
                        result.row = y;
                        result.column = x - columnCount + 1;

                        // console.log( "grid:result1", result );

                        return result;
                    }
                }
            }

            // console.log( "grid:result2", result );

            return result;
        },

        cellHasFruit( row, column ) {
            let result = false;

            const fruitsController = AP.plate.modal.fruitsController;
            const fruits = fruitsController.fruits;

            for ( const fruit of fruits ) {
                const fruitPosition = fruit.gridPosition;

                if (
                    fruitPosition.column <= column &&
                    column <= fruitPosition.column + fruit.columnSpan - 1 &&
                    fruitPosition.row <= row &&
                    row <= fruitPosition.row + fruit.rowSpan - 1
                ) {
                    result = true;

                    break;
                }
            }

            return result;
        },

        // ===================== Placche a blocchi =====================

        /**
         * Set degli id slot occupati dai frutti (placche a blocchi).
         * @param {Array} fruits
         * @param {Fruit} [excludeFruit] - frutto da escludere (es. quello in drag)
         * @returns {Set<string>}
         */
        collectOccupiedSlotIds( fruits, excludeFruit ) {
            const occupied = new Set();

            for ( const fruit of fruits ) {
                if ( excludeFruit && fruit == excludeFruit ) {
                    continue;
                }
                for ( const cellId of fruit.cellIds ) {
                    occupied.add( String( cellId.id ) );
                }
            }

            return occupied;
        },

        /**
         * Verifica che gli slot slotIndex..slotIndex+span-1 di un blocco siano liberi.
         */
        isBlockRunFree( block, slotIndex, span, occupiedSlotIds ) {
            if ( slotIndex < 0 || slotIndex + span > block.cells.length ) {
                return false;
            }

            for ( let i = slotIndex; i < slotIndex + span; i++ ) {
                if ( occupiedSlotIds.has( String( block.cells[i].id ) ) ) {
                    return false;
                }
            }

            return true;
        },

        /**
         * Prima posizione libera per un frutto su una placca a blocchi:
         * cerca in ogni blocco compatibile (stesso orientamento celle) una
         * sequenza di slot liberi della lunghezza richiesta.
         * @returns {{cell: Cell}|null}
         */
        findFirstFreeBlockPosition( plate, span, fruitOrientation, fruits ) {
            const occupied = utils.collectOccupiedSlotIds( fruits );

            for ( const block of plate.blocks ) {
                if ( fruitOrientation && block.cellOrientation != fruitOrientation ) {
                    continue;
                }

                for ( let s = 0; s + span <= block.cells.length; s++ ) {
                    if ( utils.isBlockRunFree( block, s, span, occupied ) ) {
                        return { cell: block.cells[s] };
                    }
                }
            }

            return null;
        },

        /**
         * Cella di ancoraggio più vicina alla posizione di rilascio, fra i blocchi
         * con lo stesso orientamento del frutto e con spazio libero sufficiente.
         * @returns {{cell: Cell}|null}
         */
        findNearestBlockAnchor( plate, fruit, dropPosition, fruits ) {
            const span = Math.max( fruit.rowSpan, fruit.columnSpan );
            const occupied = utils.collectOccupiedSlotIds( fruits, fruit );

            let best = null;
            let bestDistance = Infinity;

            for ( const block of plate.blocks ) {
                if ( block.cellOrientation != fruit.orientation ) {
                    continue;
                }

                for ( let s = 0; s + span <= block.cells.length; s++ ) {
                    const cell = block.cells[s];

                    const distance =
                        Math.pow( cell.left - dropPosition.left, 2 ) +
                        Math.pow( cell.top - dropPosition.top, 2 );

                    if ( distance < bestDistance && utils.isBlockRunFree( block, s, span, occupied ) ) {
                        bestDistance = distance;
                        best = { cell: cell };
                    }
                }
            }

            return best;
        },
    };

    class FruitGridPosition {
        constructor( row, column ) {
            this.row = row;
            this.column = column;
        }
    }

    class Rectangle {
        constructor( width, height, orientationValue ) {
            this.orientation = orientationValue;
            this.width = orientationValue == orientation.VERTICAL ? height : width;
            this.height = orientationValue == orientation.VERTICAL ? width : height;

            this._$element = null;

            this._top = null;
            this._bottom = null;
            this._left = null;
            this._right = null;
        }

        get $element() {
            return this._$element;
        }

        set $element( value ) {
            this._$element = value;
        }

        get top() {
            return this._top;
        }

        set top( value ) {
            this._top = value;

            this._bottom = this._top + this.height;
        }

        get bottom() {
            return this._bottom;
        }

        get left() {
            return this._left;
        }

        set left( value ) {
            this._left = value;

            this._right = this._left + this.width;
        }

        get right() {
            return this._right;
        }

        isSquare() {
            return this.width == this.height;
        }
    }

    class Plate extends Rectangle {
        constructor( args ) {
            super( args.width, args.height, args.orientation );

            this.id = args.id;
            this.code = args.code;
            this.image = args.image;
            this.grid = args.grid;
            this.isSpecial = args.isSpecial;
            this.cellOrientation = args.cellOrientation;

            // Placche a blocchi (configurazione su DB): array di blocchi
            // { left, top, width, height, cellOrientation, orientationMode, slots: [{id, order}] }
            // Le coordinate sono in px (scala 1mm = 1px).
            this.blocks = args.blocks || null;

            // callback (blockOrder) per la rotazione del singolo blocco dal preventivo
            this.onRotateBlock = args.onRotateBlock || null;

            if ( this.isBlockPlate() ) {
                // width/height sono le dimensioni del canvas (sfondo placca),
                // già calcolate per l'orientamento corrente: annulla lo swap
                // width/height fatto da Rectangle
                this.width = args.width;
                this.height = args.height;
            }
        }

        isBlockPlate() {
            return !!( this.blocks && this.blocks.length );
        }

        /**
         * Creates HTML nodes and inserts them in the DOM to visualize grid property
         */
        drawGridWithin( $rootNode ) {
            if ( this.isBlockPlate() ) {
                this.drawBlocksWithin( $rootNode );
                return;
            }

            $rootNode.empty();

            const $plateBackground = $( "<div/>", {
                class: "plate-background",
                id: "plate-background",
                css: {
                    width: `${this.width}px`,
                    height: `${this.height}px`,
                    "background-image": `url('${this.image}')`,
					position: 'relative',
                },
                appendTo: $rootNode,
            } );

			$( "#plate-background" ).append('<div class="attributes" style="position: absolute; width: 100%; height: 100%;"></div>')

            const platePosition = $plateBackground.position();

            this.top = platePosition.top;
            this.left = platePosition.left;

            const $plateLayers = $( "<div/>", {
                id: "plate-layers",
                appendTo: $plateBackground,
            } );

            // Inizializza le dimensioni delle celle basandosi sul tipo
            /*
            for ( let i = 0; i < this.grid.length; i++ ) {
                for ( let j = 0; j < this.grid[i].length; j++ ) {
                    const cell = this.grid[i][j];
                    const cellDimensions = constants.GRID_CELL_DIMENSIONS[cell];
                    if ( cellDimensions ) {
                        cell.height = cellDimensions.height;
                        cell.width = cellDimensions.width;
                    }
                }
            }
            */

            const plateCSS = {
                "grid-template-rows": "",
                "grid-template-columns": "",
            };

            const gridTemplateRows = [];
            const gridTemplateColumns = [];

            for ( let i = 0; i < this.grid.length; i++ ) {
                gridTemplateRows.push( 0 );
            }

            for ( let i = 0; i < this.grid[0].length; i++ ) {
                gridTemplateColumns.push( 0 );
            }

            for ( let i = 0; i < this.grid.length; i++ ) {
                const row = this.grid[i];

                // console.log( "this.grid[i]", this.grid[i] );

                const maxCellHeight = Math.max( ...row.map( ( x ) => x.height ) );

                // console.log( "cell.maxCellHeight", maxCellHeight );

                gridTemplateRows[i] = maxCellHeight;
            }

            for ( let i = 0; i < this.grid[0].length; i++ ) {
                const cells = [];

                for ( let j = 0; j < this.grid.length; j++ ) {
                    const cell = this.grid[j][i];

                    cells.push( cell );
                }

                const minCellWidth = Math.min( ...cells.map( ( x ) => x.width ) );

                gridTemplateColumns[i] = minCellWidth;
            }

            plateCSS["grid-template-rows"] = gridTemplateRows
                .map( ( x ) => `${x}px` )
                .join( " " );

            plateCSS["grid-template-columns"] = gridTemplateColumns
                .map( ( x ) => `${x}px` )
                .join( " " );

            const $plateGrid = $( "<div/>", {
                id: "plate-grid",
                css: plateCSS,
                appendTo: $plateLayers,
            } );

            const $fruits = $( "<div/>", {
                id: "quotation-plate-fruits",
                appendTo: $plateLayers,
            } );

            for ( let y = 1; y <= this.grid.length; y++ ) {
                const row = this.grid[y - 1];

                for ( let x = 1; x <= row.length; x++ ) {
                    const cell = row[x - 1];

                    const $plateCell = $( "<div/>", {
                        class: `grid-column p${x} ${cell.type == CELL_TYPE.PROHIBITED
                            ? "prohibited"
                            : ""
                        }`,
                        css: {
                            "grid-row": `${y} / ${y + 1}`,
                            "grid-column": `${x} / ${x + 1}`,
                        },
                        appendTo: $plateGrid,
                    } );

                    cell.$element = $plateCell;

                    if ( cell.type != CELL_TYPE.PROHIBITED ) {
                        const $cellLabel = $( "<span/>", {
                            // text: `(${x}, ${y})`,
                            text: "",
                            class: "position-label",
                            css: {
                                "font-model": "8px",
                            },
                            appendTo: $plateCell,
                        } );
                    }

                    // console.log("cell.gridTemplateRows", gridTemplateRows)
                    // console.log( "cell.gridTemplateRows", gridTemplateColumns );

                    cell.height = gridTemplateRows[y - 1];
                    cell.width = gridTemplateColumns[x - 1];

                    const cellPosition = $plateCell.position();

                    // console.log( "cell.height", cell.height );
                    // console.log( "cell.width", cell.width );

                    cell.top = cellPosition.top;
                    cell.left = cellPosition.left;
                }
            }
        }

        /**
         * Rendering per le placche a blocchi: ogni blocco è un contenitore
         * posizionato in assoluto (margini in mm, scala 1mm = 1px) con dentro
         * gli slot in fila (HOR) o in colonna (VER).
         *
         * Costruisce anche this.grid in formato compatibile con la logica
         * esistente: un blocco HOR contribuisce con una riga di n celle,
         * un blocco VER con n righe da una cella.
         */
        drawBlocksWithin( $rootNode ) {
            $rootNode.empty();

            const $plateBackground = $( "<div/>", {
                class: "plate-background",
                id: "plate-background",
                css: {
                    width: `${this.width}px`,
                    height: `${this.height}px`,
                    "background-image": `url('${this.image}')`,
                    position: "relative",
                },
                appendTo: $rootNode,
            } );

            $( "#plate-background" ).append( '<div class="attributes" style="position: absolute; width: 100%; height: 100%;"></div>' );

            const platePosition = $plateBackground.position();

            this.top = platePosition.top;
            this.left = platePosition.left;

            const $plateLayers = $( "<div/>", {
                id: "plate-layers",
                appendTo: $plateBackground,
            } );

            // bounding box dei blocchi: la griglia occupa solo questo spazio,
            // centrato nel canvas dalla flex di .plate-background (come legacy)
            let bboxWidth = 0;
            let bboxHeight = 0;
            for ( const block of this.blocks ) {
                bboxWidth = Math.max( bboxWidth, block.left + block.width );
                bboxHeight = Math.max( bboxHeight, block.top + block.height );
            }

            const $plateGrid = $( "<div/>", {
                id: "plate-grid",
                css: {
                    display: "block",
                    position: "relative",
                    width: `${bboxWidth}px`,
                    height: `${bboxHeight}px`,
                },
                appendTo: $plateLayers,
            } );

            const $fruits = $( "<div/>", {
                id: "quotation-plate-fruits",
                appendTo: $plateLayers,
            } );

            this.grid = [];

            const slotDimensions = constants.GRID_CELL_DIMENSIONS[CELL_TYPE.FREE];

            for ( let blockIndex = 0; blockIndex < this.blocks.length; blockIndex++ ) {
                const block = this.blocks[blockIndex];
                const isHorizontal = block.cellOrientation == orientation.HORIZONTAL;

                const $block = $( "<div/>", {
                    class: "plate-block",
                    css: {
                        position: "absolute",
                        top: `${block.top}px`,
                        left: `${block.left}px`,
                        width: `${block.width}px`,
                        height: `${block.height}px`,
                    },
                    appendTo: $plateGrid,
                } );

                if ( this.onRotateBlock && !!block.rotatable ) {
                    const blockOrder = block.order;
                    const self = this;

                    $( "<button/>", {
                        type: "button",
                        class: "plate-block-rotate",
                        title: "Ruota blocco",
                        html: '<i class="fas fa-sync-alt"></i>',
                        css: {
                            // dentro al blocco: fuori verrebbe tagliato
                            // dall'overflow hidden dei layer della placca
                            position: "absolute",
                            top: "4px",
                            right: "4px",
                            width: "32px",
                            height: "32px",
                            padding: "0",
                            "border-radius": "50%",
                            border: "1px solid #999",
                            background: "rgba(255, 255, 255, 0.9)",
                            "box-shadow": "0 1px 3px rgba(0, 0, 0, 0.3)",
                            cursor: "pointer",
                            "font-size": "14px",
                            "line-height": "1",
                            "z-index": 10,
                        },
                        click: function( event ) {
                            event.preventDefault();
                            event.stopPropagation();
                            self.onRotateBlock( blockOrder );
                        },
                        appendTo: $block,
                    } );
                }

                block.cells = [];

                let rowForHorizontalBlock = null;

                if ( isHorizontal ) {
                    rowForHorizontalBlock = [];
                    this.grid.push( rowForHorizontalBlock );
                }

                for ( let slotIndex = 0; slotIndex < block.slots.length; slotIndex++ ) {
                    const slotData = block.slots[slotIndex];

                    // Rectangle scambia width/height per i blocchi VER
                    const cell = new Cell(
                        slotDimensions.width,
                        slotDimensions.height,
                        block.cellOrientation,
                        CELL_TYPE.FREE,
                        slotData.id,
                        slotData.order,
                    );

                    cell.blockIndex = blockIndex;
                    cell.slotIndex = slotIndex;
                    cell.block = block;

                    const offsetTop = isHorizontal ? 0 : slotIndex * cell.height;
                    const offsetLeft = isHorizontal ? slotIndex * cell.width : 0;

                    const $plateCell = $( "<div/>", {
                        class: "grid-column",
                        css: {
                            position: "absolute",
                            top: `${offsetTop}px`,
                            left: `${offsetLeft}px`,
                            width: `${cell.width}px`,
                            height: `${cell.height}px`,
                        },
                        appendTo: $block,
                    } );

                    cell.$element = $plateCell;

                    // coordinate assolute rispetto all'origine della placca
                    cell.top = block.top + offsetTop;
                    cell.left = block.left + offsetLeft;

                    block.cells.push( cell );

                    if ( isHorizontal ) {
                        cell.gridRow = this.grid.length - 1;
                        cell.gridColumn = rowForHorizontalBlock.length;
                        rowForHorizontalBlock.push( cell );
                    } else {
                        cell.gridRow = this.grid.length;
                        cell.gridColumn = 0;
                        this.grid.push( [ cell ] );
                    }
                }
            }
        }
    }

    class Cell extends Rectangle {
        constructor( width, height, orientation, type, id, order ) {
            super( width, height, orientation );

            this.type = type;
            this.id = id; // ID della cella dalla griglia
            this.order = order;
            this._position = null;
        }

        get position() {
            return this._position;
        }

        set position( position ) {
            this._position = position;
        }

        setIsOverlapped( value ) {

            // console.log( "this.$element", this.$element );

            if ( value ) {
                this.$element.addClass( "overlapped" );
            } else {
                this.$element.removeClass( "overlapped" );
            }
        }

        setIfOverlappedBy( fruitPosition ) {
            const cellRectangle = {
                top: this.top,
                bottom: this.bottom,
                left: this.left,
                right: this.right,
            };

            this.setIsOverlapped(
                utils.doRectanglesCollide( fruitPosition, cellRectangle ),
            );
        }
    }

    class Fruit extends Rectangle {
        constructor( args ) {
            // console.log( "constructor:Fruit:args", args );

            super( args.width, args.height, args.orientation );

            // console.log( "Fruit:orientation", orientation.VERTICAL );
            // console.log( "this.orientation", this.orientation );

            this.rowSpan =
                this.orientation == orientation.VERTICAL
                    ? args.columnSpan
                    : args.rowSpan;
            this.columnSpan =
                this.orientation == orientation.VERTICAL
                    ? args.rowSpan
                    : args.columnSpan;

            this.id = args.id;
            this.fruitId = args.fruitId; // ID del prodotto frutto (può essere duplicato)
            this.code = args.code;
            this.name = args.name;
            this.image = args.image;
            this.cellIds = []; // Array di ID delle celle occupate dal frutto

            this._gridPosition = null;
            this._originalGridPosition = null;
        }

        get gridPosition() {
            return this._gridPosition;
        }

        set gridPosition( value ) {
            this._gridPosition = value;

            if (
                Math.sign( this._gridPosition.row ) >= 0 &&
                Math.sign( this._gridPosition.column ) >= 0
            ) {

                // console.log( "this._gridPosition", this._gridPosition );

                const { top, left } = utils.extractTopLeftPositionFrom(
                    this._gridPosition,
                );

                this.top = top;
                this.left = left;

                // Aggiorna gli ID delle celle occupate dal frutto
                this.updateCellIds();
            }
        }

        updateCellIds() {
            this.cellIds = [];

            const fruitsController = AP.plate.modal.fruitsController;
            if ( !fruitsController || !fruitsController.plate || !fruitsController.plate.grid ) {
                return;
            }

            const grid = fruitsController.plate.grid;

            // Cella di ancoraggio: nelle placche a blocchi il frutto non deve
            // mai estendersi oltre il proprio blocco
            const anchorRow = grid[this._gridPosition.row];
            const anchorCell = anchorRow ? anchorRow[this._gridPosition.column] : null;
            const anchorBlockIndex = anchorCell ? anchorCell.blockIndex : undefined;

            // Calcola tutte le celle occupate dal frutto
            for ( let row = this._gridPosition.row; row < this._gridPosition.row + this.rowSpan && row < grid.length; row++ ) {
                for ( let col = this._gridPosition.column; col < this._gridPosition.column + this.columnSpan && col < grid[row].length; col++ ) {
                    if ( grid[row][col] && grid[row][col].id ) {
                        if ( anchorBlockIndex !== undefined && grid[row][col].blockIndex !== anchorBlockIndex ) {
                            continue;
                        }

                        this.cellIds.push( {
                            id: grid[row][col].id,
                            order: grid[row][col].order
                        } );
                    }
                }
            }
        }

        initDraggableWidget( controller ) {
            const self = this;

            self._$element.draggable( {
                containment: "#quotation-plate-fruits",
                distance: MIN_DISTANCE_BEFORE_DRAGGING,
                // grid: [ATOMIC_width],
                revertDuration: 250,
                start: function( event, ui ) {
                    controller.onStartDragging( self, event, ui );
                },
                drag: function( event, ui ) {
                    controller.onDragging( self, event, ui );
                },
                stop: function( event, ui ) {
                    controller.onStopDragging( self, event, ui );
                },
            } );
        }

        isOverlappingWith( otherFruit ) {
            let result = true;

            const x5 = Math.max( this.left, otherFruit.left );
            const x6 = Math.min(
                this.left + this.width,
                otherFruit.left + otherFruit.width,
            );

            const y5 = Math.max( this.top, otherFruit.top );
            const y6 = Math.min(
                this.top + this.height,
                otherFruit.top + otherFruit.height,
            );

            if ( x5 >= x6 ) {
                result = false;
            }

            if ( y5 >= y6 ) {
                result = false;
            }

            return result;
        }

        canSwapWith( otherFruit ) {
            // Only if both are in the same position and are of equal model
            return (
                this.gridPosition.row == otherFruit.gridPosition.row &&
                this.gridPosition.column == otherFruit.gridPosition.column &&
                this.top + this.height == otherFruit.top + otherFruit.height &&
                this.left + this.width == otherFruit.left + otherFruit.width
            );
        }

        swapPositionWith( otherFruit ) {
            this.gridPosition = otherFruit.gridPosition;
            otherFruit.gridPosition = this._originalGridPosition;
        }

        fitsWithin( containmentGrid ) {
            const columnSpan = {
                start: this.gridPosition.column,
                end: this.gridPosition.column + this.width / FREE_CELL_WIDTH,
            };

            const rowSpan = {
                start: this.gridPosition.row,
                end: this.gridPosition.row + this.height / FREE_CELL_HEIGHT,
            };

            return (
                0 <= columnSpan.start &&
                columnSpan.end <= containmentGrid[0].length &&
                0 <= rowSpan.start &&
                rowSpan.end <= containmentGrid.length
            );
        }

        /**
         * Calculates a separation vector that moves the given overlapping Fruit away from this Fruit
         * @param {Array} otherFruit
         * @returns Array of two elements: [x, y]
         */
        calculateSeparation( otherFruit ) {
            const result = [ 0, 0 ];

            const thisCenterPoint = [
                this.left + this.width / 2,
                this.top + this.height / 2,
            ];

            const otherCenterPoint = [
                otherFruit.left + otherFruit.width / 2,
                otherFruit.top + otherFruit.height / 2,
            ];

            const separationVector = [
                otherCenterPoint[0] - thisCenterPoint[0],
                otherCenterPoint[1] - thisCenterPoint[1],
            ];

            const vectorLength = Math.sqrt(
                Math.pow( separationVector[0], 2 ) +
                Math.pow( separationVector[1], 2 ),
            ); // Pythagorean theorem

            if ( vectorLength == 0 ) {
                return result; // Avoid division by zero
            }

            const normalizedVector = [
                separationVector[0] / vectorLength,
                separationVector[1] / vectorLength,
            ];

            const moveAmountX = FREE_CELL_WIDTH; // Adjust it on your needs
            const moveAmountY = FREE_CELL_HEIGHT; // Adjust it on your needs

            result[0] = normalizedVector[0] * moveAmountX;
            result[1] = normalizedVector[1] * moveAmountY;

            return result;
        }

        hasChangedPosition() {
            return (
                this._originalGridPosition.column != this.gridPosition.column ||
                this._originalGridPosition.row != this.gridPosition.row
            );
        }

        makePositionSnapshot() {
            this._originalGridPosition = new FruitGridPosition(
                this.gridPosition.row,
                this.gridPosition.column,
            );
        }

        restorePositionToLastSnapshot() {
            this.gridPosition = this._originalGridPosition;
        }

        startDragging() {
            this.$element.addClass( "is-dragging" );
        }

        stopDragging() {
            this.$element.removeClass( "is-dragging" );
        }

        onEnterInProhibitedPosition() {
            this.$element.addClass( "is-in-prohibited-position" );
        }

        onExitFromProhibitedPosition() {
            this.$element.removeClass( "is-in-prohibited-position" );
        }

        drawWithin( $rootNode ) {

            const $fruit = $( "<div/>", {
                id: this.id,
                class: "plate-draggable-fruit",
                css: {
                    top: `${this.top}px`,
                    left: `${this.left}px`,
                    width: `${this.width}px`,
                    height: `${this.height}px`,
                },
                mouseenter: function() {
                    $( `div[data-fruit-id="${this.id}"]` ).css( "background-color", "#a3fda170" );
                },
                mouseleave: function() {
                    $( `div[data-fruit-id="${this.id}"]` ).css( "background-color", "" );
                },
                appendTo: $rootNode,
            } );

            const imgCSS = {
                width: `${this.width}px`,
                height: `${this.height}px`,
            };

            if ( this.orientation == orientation.VERTICAL ) {

                const tmp = imgCSS.width;
                imgCSS.width = imgCSS.height;
                imgCSS.height = tmp;

                if ( this.isSquare() ) {
                    imgCSS.transform = "rotate(90deg)";
                } else {
                    imgCSS.transform = "rotate(90deg) translate(-50%, 0%)";
                }
            }

            const $image = $( "<img/>", {
                src: this.image,
                class: "fruit-img",
                alt: this.id,
                title: this.id,
                css: imgCSS,
                appendTo: $fruit,
            } );

            this.$element = $fruit;
        }

        /**
         * Renders Fruit based on current position
         */
        render() {
            this.$element.css( {
                left: this.left,
                top: this.top,
            } );
        }
    }

    class FruitsController {
        constructor( args ) {

            // console.log( "FruitsController initialized", args.plate );

            this.plate = args.plate;
            this.fruits = args.fruits;
        }

        /**
         *	Creates HTML nodes and inserts them in the DOM to visualize fruits on the grid
         */
        drawFruitsWithin( $rootNode ) {
            for ( const fruit of this.fruits ) {
                fruit.drawWithin( $rootNode );
            }
        }

        /**
         * Initializes jQuery UI Draggable Widget for each fruit
         */
        makeFruitsDraggable() {
            for ( const fruit of this.fruits ) {
                fruit.initDraggableWidget( this );
            }
        }

        /**
         * Verifica se c'è spazio per posizionare il frutto sulla placca
         * (senza spostare i frutti già presenti).
         * @param {Object} selectedFruit - frutto mappato da mapFruitForPlate
         * @returns {boolean}
         */
        canPlaceFruit( selectedFruit ) {
            if ( this.plate.isBlockPlate() ) {
                const span = selectedFruit.columnSpan || 1;

                return !!(
                    utils.findFirstFreeBlockPosition( this.plate, span, this.plate.cellOrientation, this.fruits ) ||
                    utils.findFirstFreeBlockPosition( this.plate, span, null, this.fruits )
                );
            }

            const tempFruit = new Fruit( {
                width: selectedFruit.width,
                height: selectedFruit.height,
                rowSpan: selectedFruit.rowSpan,
                columnSpan: selectedFruit.columnSpan,
                orientation: this.plate.cellOrientation,
                id: selectedFruit.id,
                fruitId: selectedFruit.fruitId,
            } );

            const freePosition = utils.findFirstFreePosition( tempFruit );

            return freePosition.row != null && freePosition.column != null;
        }

        // renamed from "onSelectFruit"
        addFruitToPlate( selectedFruit ) {

            // console.log( "addFruitToPlate:this.plate", this.plate );
            // console.log( "addFruitToPlate:selectedFruit.image.uri", selectedFruit.image?.uri );
            // console.log( "addFruitToPlate:selectedFruit", selectedFruit );

            if ( this.plate.isBlockPlate() ) {
                this.addFruitToBlockPlate( selectedFruit );
                return;
            }

            const fruitObj = new Fruit( {
                width: selectedFruit.width,
                height: selectedFruit.height,
                rowSpan: selectedFruit.rowSpan,
                columnSpan: selectedFruit.columnSpan,
                orientation: this.plate.cellOrientation,
                id: selectedFruit.id, // ID univoco già generato da createFruit()
                fruitId: selectedFruit.fruitId, // ID del prodotto frutto originale
                code: selectedFruit.code,
                name: selectedFruit.name,
                image: selectedFruit.image,
            } );

            const freePosition = utils.findFirstFreePosition( fruitObj );

            // console.log( "freePosition", freePosition );

            if ( freePosition.row != null && freePosition.column != null ) {
                fruitObj.gridPosition = new FruitGridPosition(
                    freePosition.row,
                    freePosition.column,
                );

                this.fruits.push( fruitObj );

                fruitObj.drawWithin( $( "#quotation-plate-fruits" ) );
                fruitObj.initDraggableWidget( this );
            }

        }

        /**
         * Aggiunge un frutto alla prima posizione libera di una placca a blocchi.
         * Il frutto assume l'orientamento del blocco che lo ospita: prova prima
         * i blocchi con l'orientamento corrente della placca, poi gli altri.
         */
        addFruitToBlockPlate( selectedFruit ) {
            const span = selectedFruit.columnSpan || 1;

            let target = utils.findFirstFreeBlockPosition(
                this.plate,
                span,
                this.plate.cellOrientation,
                this.fruits,
            );

            if ( !target ) {
                // nessuno spazio nei blocchi con l'orientamento della placca:
                // prova nei blocchi fissi con l'altro orientamento
                target = utils.findFirstFreeBlockPosition(
                    this.plate,
                    span,
                    null,
                    this.fruits,
                );
            }

            if ( !target ) {
                return;
            }

            const fruitObj = new Fruit( {
                width: selectedFruit.width,
                height: selectedFruit.height,
                rowSpan: selectedFruit.rowSpan,
                columnSpan: selectedFruit.columnSpan,
                orientation: target.cell.block.cellOrientation,
                id: selectedFruit.id,
                fruitId: selectedFruit.fruitId,
                code: selectedFruit.code,
                name: selectedFruit.name,
                image: selectedFruit.image,
            } );

            fruitObj.gridPosition = new FruitGridPosition(
                target.cell.gridRow,
                target.cell.gridColumn,
            );

            this.fruits.push( fruitObj );

            fruitObj.drawWithin( $( "#quotation-plate-fruits" ) );
            fruitObj.initDraggableWidget( this );
        }

        addFruitToPositions( selectedFruit, positionIds ) {

            // Trova la posizione della prima cella nell'array
            // (confronto come stringhe: gli id possono essere guid legacy
            // o interi, e dal DB arrivano comunque come stringhe)
            const grid = this.plate.grid;
            let foundPosition = null;
            let anchorCell = null;

            for ( let y = 0; y < grid.length && !foundPosition; y++ ) {
                for ( let x = 0; x < grid[y].length && !foundPosition; x++ ) {
                    const cell = grid[y][x];

                    // Verifica se questa cella è la prima nell'array di positionIds
                    if ( String( cell.id ) === String( positionIds[0] ) ) {
                        foundPosition = { row: y, column: x };
                        anchorCell = cell;
                    }
                }
            }

            // nelle placche a blocchi il frutto assume l'orientamento del blocco
            const fruitOrientation = ( this.plate.isBlockPlate() && anchorCell )
                ? anchorCell.block.cellOrientation
                : this.plate.cellOrientation;

            const fruitObj = new Fruit( {
                width: selectedFruit.width,
                height: selectedFruit.height,
                rowSpan: selectedFruit.rowSpan,
                columnSpan: selectedFruit.columnSpan,
                orientation: fruitOrientation,
                id: selectedFruit.id, // ID univoco già generato da createFruit()
                fruitId: selectedFruit.fruitId, // ID del prodotto frutto originale
                code: selectedFruit.code,
                name: selectedFruit.name,
                image: selectedFruit.image,
            } );

            if ( foundPosition ) {
                fruitObj.gridPosition = new FruitGridPosition(
                    foundPosition.row,
                    foundPosition.column,
                );

                this.fruits.push( fruitObj );

                fruitObj.drawWithin( $( "#quotation-plate-fruits" ) );
                fruitObj.initDraggableWidget( this );
            } else if ( this.plate.isBlockPlate() ) {
                // positionIds sono GUID legacy, non corrispondono agli slot interi del blocco:
                // posiziona il frutto nel primo slot libero disponibile
                this.addFruitToBlockPlate( selectedFruit );
            } else {
                console.error( "addFruitToPositions: Position not found for positionIds", positionIds );
            }

        }

        removeFruit( fruitId ) {
            const index = this.fruits.findIndex( fruit => fruit.id === fruitId );
            if ( index > -1 ) {
                const fruit = this.fruits[index];
                if ( fruit.$element ) {
                    fruit.$element.remove();
                }
                this.fruits.splice( index, 1 ); // modifica in place
            }
        }

        updateFruit( fruitId, changes = {} ) {
            this.fruits.forEach( fruit => {
                if ( fruit.id === fruitId ) {
                    // console.log( "trovato", fruit.id );
                    Object.assign( fruit, changes );

                    // Se l'immagine è cambiata, aggiorna il DOM
                    if ( changes.image && fruit.$element ) {
                        fruit.$element.find( "img.fruit-img" ).attr( "src", changes.image );
                    }
                }
            } );
        }


        /*
        removeFruit( fruitId ) {
            this.fruits = this.fruits.filter( fruit => fruit.id !== fruitId );
        }
        */

        restoreAllFruitPositions() {
            for ( const fruit of this.fruits ) {
                fruit.restorePositionToLastSnapshot();
            }
        }

        isFruitInProhibitedPosition( fruitRectangle ) {
            let result = false;

            for ( const row of this.plate.grid ) {
                if ( result ) {
                    break;
                }

                for ( const cell of row ) {
                    if ( cell.type == CELL_TYPE.PROHIBITED ) {
                        const cellRectangle = {
                            top: cell.top,
                            bottom: cell.top + cell.height,
                            left: cell.left,
                            right: cell.left + cell.width,
                        };

                        if (
                            utils.doRectanglesCollide(
                                fruitRectangle,
                                cellRectangle,
                            )
                        ) {
                            result = true;

                            break;
                        }
                    }
                }
            }

            return result;
        }

        renderFruits() {
            for ( const fruit of this.fruits ) {
                fruit.render();
            }
        }

        hasOverlappedFruits() {
            return this.fruits.some( ( fruit ) => {
                return this.fruits.some( ( otherFruit ) =>
                    otherFruit != fruit
                        ? fruit.isOverlappingWith( otherFruit )
                        : false,
                );
            } );
        }

        moveAwayAllFruitsFrom( targetFruit ) {
            let result = true;

            const filteredFruits = this.fruits.filter( ( f ) => f != targetFruit );

            const MAX_ITERATIONS = 1000;

            let counter = 0;
            while ( this.hasOverlappedFruits() ) {
                if ( counter > MAX_ITERATIONS ) {
                    result = false;

                    console.error( "DANGER! Potential infinite loop." );

                    return result;
                }

                const overlapVectors = [];

                for ( const fruit of filteredFruits ) {
                    const vector = this.generateNormalizedOverlapVector( fruit );

                    if ( vector[0] != 0 || vector[1] != 0 ) {
                        overlapVectors.push( [ fruit, vector ] );
                    }
                }

                for ( const [ fruit, vector ] of overlapVectors ) {
                    const isSuccess = this.translateFruitByVector(
                        fruit,
                        vector,
                    );

                    if ( !isSuccess ) {
                        result = false;

                        return result;
                    }
                }

                counter++;
            }

            return result;
        }

        generateNormalizedOverlapVector( fruit ) {
            const vector = [ 0, 0 ];

            const filteredFruits = this.fruits.filter( ( f ) => f != fruit );

            for ( const otherFruit of filteredFruits ) {
                if ( fruit.isOverlappingWith( otherFruit ) ) {
                    const innerVector = fruit.calculateSeparation( otherFruit );

                    vector[0] += innerVector[0];
                    vector[1] += innerVector[1];
                }
            }

            return vector;
        }

        translateFruitByVector( fruit, vector ) {
            const convertedGridPosition = {
                column: vector[0] / FREE_CELL_WIDTH,
                row: vector[1] / FREE_CELL_HEIGHT,
            };

            fruit.gridPosition = new FruitGridPosition(
                fruit.gridPosition.row - convertedGridPosition.row,
                fruit.gridPosition.column - convertedGridPosition.column,
            );


            const fruitRectangle = {
                top: fruit.top,
                bottom: fruit.top + fruit.height,
                left: fruit.left,
                right: fruit.left + fruit.width,
            };

            return (
                !this.isFruitInProhibitedPosition( fruitRectangle ) &&
                fruit.fitsWithin( this.plate.grid )
            );
        }


        /**
         * Triggered when dragging starts
         * @param {Fruit} fruit
         * @param {Event} event
         * @param {object} ui
         */
        onStartDragging( fruit, event, ui ) {

            fruit.startDragging();

            for ( const fruit of this.fruits ) {
                fruit.makePositionSnapshot();
            }
        }

        /**
         * Triggered while the mouse is moved during the dragging, immediately before the current move happens.
         * @param {Fruit} fruit
         * @param {Event} event
         * @param {object} ui The values may be changed to modify where the element will be positioned. This is useful for custom containment, snapping, etc
         */
        onDragging( fruit, event, ui ) {
            let newFruitPosition = {
                top: ui.position.top,
                bottom: ui.position.top + fruit.height,
                left: ui.position.left,
                right: ui.position.left + fruit.width,
            };

            // console.log( "onDragging;newFruitPosition", newFruitPosition );
            // console.log( "onDragging;ui", ui );

            if ( this.plate.isBlockPlate() ) {
                const anchor = utils.findNearestBlockAnchor(
                    this.plate,
                    fruit,
                    newFruitPosition,
                    this.fruits,
                );

                for ( const row of this.plate.grid ) {
                    for ( const cell of row ) {
                        cell.setIsOverlapped( false );
                    }
                }

                if ( anchor ) {
                    const anchorPosition = {
                        top: anchor.cell.top,
                        bottom: anchor.cell.top + fruit.height,
                        left: anchor.cell.left,
                        right: anchor.cell.left + fruit.width,
                    };

                    for ( const row of this.plate.grid ) {
                        for ( const cell of row ) {
                            cell.setIfOverlappedBy( anchorPosition );
                        }
                    }
                }

                return;
            }

            const { row, column } = utils.convertAbsolutePositionToGridPosition(
                ui,
                newFruitPosition,
            );

            // console.log( "onDragging:row", row );
            // console.log( "onDragging:column", column );

            if ( row == null || column == null ) {
                return;
            }

            const gridPosition = new FruitGridPosition( row, column );
            const { top, left } = utils.extractTopLeftPositionFrom( gridPosition );

            newFruitPosition = {
                top: top,
                bottom: top + fruit.height,
                left: left,
                right: left + fruit.width,
            };

            for ( const row of this.plate.grid ) {
                for ( const cell of row ) {
                    cell.setIfOverlappedBy( newFruitPosition );
                }
            }

            if ( this.isFruitInProhibitedPosition( newFruitPosition ) ) {
                fruit.onEnterInProhibitedPosition();
            } else {
                fruit.onExitFromProhibitedPosition();
            }
        }

        /**
         * Triggered when dragging stops
         * @param {Fruit} fruit
         * @param {Event} event
         * @param {object} ui
         */
        onStopDragging( fruit, event, ui ) {
            for ( const row of this.plate.grid ) {
                for ( const cell of row ) {
                    cell.setIsOverlapped( false );
                }
            }

            if ( this.plate.isBlockPlate() ) {
                const anchor = utils.findNearestBlockAnchor(
                    this.plate,
                    fruit,
                    {
                        top: ui.position.top,
                        bottom: ui.position.top + fruit.height,
                        left: ui.position.left,
                        right: ui.position.left + fruit.width,
                    },
                    this.fruits,
                );

                if ( anchor ) {
                    fruit.gridPosition = new FruitGridPosition(
                        anchor.cell.gridRow,
                        anchor.cell.gridColumn,
                    );
                } else {
                    fruit.restorePositionToLastSnapshot();
                }

                fruit.stopDragging();
                this.renderFruits();

                return;
            }

            const newFruitPosition = {
                top: ui.position.top,
                bottom: ui.position.top + fruit.height,
                left: ui.position.left,
                right: ui.position.left + fruit.width,
            };

            const { row, column } = utils.convertAbsolutePositionToGridPosition(
                ui,
                newFruitPosition,
            );
            fruit.gridPosition = new FruitGridPosition( row, column );

            const fruitPosition = {
                top: fruit.top,
                bottom: fruit.bottom,
                left: fruit.left,
                right: fruit.right,
            };

            if ( this.isFruitInProhibitedPosition( fruitPosition ) ) {
                fruit.restorePositionToLastSnapshot();
            } else {
                if ( fruit.hasChangedPosition() ) {
                    if ( this.hasOverlappedFruits() ) {
                        const otherFruit = this.fruits.find(
                            ( f ) =>
                                f != fruit &&
                                f.gridPosition.row == fruit.gridPosition.row &&
                                f.gridPosition.column ==
                                fruit.gridPosition.column,
                        );

                        if ( otherFruit && fruit.canSwapWith( otherFruit ) ) {
                            fruit.swapPositionWith( otherFruit );
                        } else {
                            const isOperationSuccessful =
                                this.moveAwayAllFruitsFrom(
                                    fruit,
                                    this.plate.grid,
                                );

                            if ( !isOperationSuccessful ) {
                                this.restoreAllFruitPositions();
                            }
                        }
                    }
                }
            }

            fruit.stopDragging();

            this.renderFruits();
        }
    }

    function setCellDimensions( width, height ) {
        FREE_CELL_WIDTH = width;
        FREE_CELL_HEIGHT = height;
    }

    return {
        constants: constants,
        orientation: orientation,
        CELL_TYPE: CELL_TYPE,
        MOVE_DIRECTION: MOVE_DIRECTION,
        utils: utils,
        setCellDimensions: setCellDimensions,
        // Models
        FruitGridPosition: FruitGridPosition,
        Rectangle: Rectangle,
        Plate: Plate,
        Cell: Cell,
        Fruit: Fruit,
        FruitsController: FruitsController
    };

} () );
