AP.namespace( "plate" );


Object.assign( AP.plate.fields, {
    modalRoot: $( "#plate-modal-root" ),
} );

$( document ).ready( function() {

    if ( AP.plate.fields.modalRoot.length ) {

        AP.plate.modal.init( { container: AP.plate.fields.modalRoot } );
    }

} );

AP.plate.modal = ( function() {

    AP.plate.constants = { GRID_CELL_DIMENSIONS: { "_": { "height": 180, "width": 45 }, "0": { "height": 105, "width": 52 } } };

    var constants = AP.plate.constants;
    var fields = AP.plate.fields;

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

            const cell = grid[ gridPosition.row ][ gridPosition.column ];

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
                    const cell = row[x];
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
    };

    class FruitGridPosition {
        constructor( row, column ) {
            this.row = row;
            this.column = column;
        }
    }

    class Rectangle {
        constructor( width, height, orientation ) {
            this.orientation = orientation;
            this.width = orientation == orientation.VERTICAL ? height : width;
            this.height = orientation == orientation.VERTICAL ? width : height;

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

            this.id              = args.id;
            this.code            = args.code;
            this.image           = args.image;
            this.grid            = args.grid;
            this.isSpecial       = args.isSpecial;
            this.cellOrientation = args.cellOrientation;
        }

        /**
         * Creates HTML nodes and inserts them in the DOM to visualize grid property
         */
        drawGridWithin( $rootNode ) {
            $rootNode.empty();

            const $plateBackground = $( "<div/>", {
                class: "plate-background",
                id: "plate-background",
                css: {
                    width: `${this.width}px`,
                    height: `${this.height}px`,
                    "background-image": `url('${this.image}')`,
                },
                appendTo: $rootNode,
            } );

            const platePosition = $plateBackground.position();

            this.top = platePosition.top;
            this.left = platePosition.left;

            const $plateLayers = $( "<div/>", {
                id: "plate-layers",
                appendTo: $plateBackground,
            } );

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

                const maxCellHeight = Math.max( ...row.map( ( x ) => x.height ) );

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
                        class: `grid-column p${x} ${
                            cell.type == CELL_TYPE.PROHIBITED
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
                            text: `(${x}, ${y})`,
                            class: "position-label",
                            css: {
                                "font-model": "8px",
                            },
                            appendTo: $plateCell,
                        } );
                    }

                    cell.height = gridTemplateRows[y - 1];
                    cell.width = gridTemplateColumns[x - 1];

                    const cellPosition = $plateCell.position();

                    cell.top = cellPosition.top;
                    cell.left = cellPosition.left;
                }
            }
        }
    }

    class Cell extends Rectangle {
        constructor( width, height, orientation, type ) {
            super( width, height, orientation );

            this.type = type;
            this._position = null;
        }

        get position() {
            return this._position;
        }

        set position( position ) {
            this._position = position;
        }

        setIsOverlapped( value ) {
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

            this.rowSpan =
                this.orientation == orientation.VERTICAL
                    ? args.columnSpan
                    : args.rowSpan;
            this.columnSpan =
                this.orientation == orientation.VERTICAL
                    ? args.rowSpan
                    : args.columnSpan;

            this.id = args.id;
            this.code = args.code;
            this.name = args.name;
            this.image = args.image;

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

            // console.log( "drawWithin", $rootNode );
            // console.log( "this.image", this.image );

            const $fruit = $( "<div/>", {
                id: this.id,
                class: "plate-draggable-fruit",
                css: {
                    top: `${this.top}px`,
                    left: `${this.left}px`,
                    width: `${this.width}px`,
                    height: `${this.height}px`,
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

        // renamed from "onSelectFruit"
        addFruitToPlate( selectedFruit ) {

            // console.log( "addFruitToPlate:fruit", selectedFruit );
            // console.log( "addFruitToPlate:selectedFruit.image", selectedFruit.image );

            const fruitObj = new Fruit( {
                width: selectedFruit.width,
                height: selectedFruit.height,
                rowSpan: selectedFruit.rowSpan,
                columnSpan: selectedFruit.columnSpan,
                orientation: this.plate.cellOrientation,
                id: selectedFruit.id,
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
                    console.log( "trovato", fruit.id );
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

            const { row, column } = utils.convertAbsolutePositionToGridPosition(
                ui,
                newFruitPosition,
            );

            // console.log( "onDragging:row", row );
            // console.log( "onDragging:column", column );

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

    var pub = {
        fruitsController: null,
    };

    const settings = {
        container: null,
    };

    var mapFruitForPlate = function( data ) {

        // console.log( "mapFruitForPlate:data", data );

        var fruit = {
            id        : data.id,
            fruitId   : data.fruit.id,
            width     : constants.GRID_CELL_DIMENSIONS[ CELL_TYPE.FREE ].width * data.fruit.positionCount,
            height    : constants.GRID_CELL_DIMENSIONS[ CELL_TYPE.FREE ].height,
            columnSpan: data.fruit.positionCount,
            rowSpan   : 1,
            code      : data.fruit.code,
            name      : data.fruit.name,
            image     : data.fruit?.horizontalImage?.uri ?? "/assets/main/img/fruit-generic.png"
        };

        return fruit;

    };

    var createFruit = function( data ) {
        // QuotationItemFruis
        // data: { position: 1, fruit: { id: "", name: "" }, items: [] }
        if ( !data.id ) {
            data.id = NM.util.uuid();
        }

        var fruit = data;

        fruit.items = new kendo.data.DataSource( {
            data: [],
            schema: {
                model: { id: "id" } // than, can i use get()
            }
        } );

        // console.log( "createFruit", fruit );

        return fruit;

    };

    var defaultDetailForm = {
        data: {
            // quotationItemId: "",
            id: "",
            quantity: 1,
            price: 0,
            product: {
                finish: {
                    id: ""
                },
                line: {
                    id: ""
                },
                model: {
                    id: "",
                    code: ""
                },
                image: {
                    id: "",
                    uri: ""
                },
                items: new kendo.data.DataSource(),
            },
            quotationZone: {
                id: ""
            },
            status: {
                id: "ACT",
                name: ""
            },
            fruits:  new kendo.data.DataSource( { // es. data: { position: 1, { fruit: { id: , name: } } }
                data: [],
                schema: {
                    model: { id: "id" }
                }
            } )
        },
        // statuses: AP.page.statuses,
        title: "Carica placca",
        canSave: false,
    };

    var defaultPlate = {
        id: "100",
        code: "508",
        image: {
            uri: "",
        },
        width: 1200, // in px
        height: 500, // in px
        orientation: {
            id: "HOR"
        },
        orientationCell: {
            id: "HOR"
        },
        grid: [
            // LEGEND:
            // "_" - empty free space
            // "0" - prohibited space
            [
                "_",
                "_",
            ],
        ],
    };

    var viewModel = new kendo.data.ObservableObject( {

        detailForm: defaultDetailForm,
        lines: new kendo.data.DataSource(),
        models: new kendo.data.DataSource(),
        finishes: new kendo.data.DataSource(),

        plate: defaultPlate,

        // productItems: new kendo.data.DataSource(),

        currentFruit: {},

        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        getFruitCount() {
            return this.get( "detailForm.data.fruits" ).total();
        },

        removeFruit( event ) {

            viewModel.get( "detailForm.data.fruits" ).remove( event.data );
            pub.fruitsController.removeFruit( event.data.id );

        },

        loadPlate: function() {

            // id from model
            var modelId = this.get( "detailForm.data.product.model.code" );
            var image = this.get( "detailForm.data.product.image" );

            // get plate/frame by code
            // for plate, code of frame is the same code of model
            const frameId = AP.page.frames
                .find( frame => frame.code === modelId )
                ?.id
                || "";

            if ( frameId == "" ) {
                AP.widget.notify( "error", "Modello [" + frameId + "] non trovato. Impossibile continuare." );
                return;
            }

            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/frames/" + frameId,
                callback: {
                    before: function( event ) {
                        alert( "ciao" );
                    },
                    done: function( xhr ) {

                        viewModel.set( "plate.id", xhr.data.id );
                        viewModel.set( "plate.code", xhr.data.code );
                        viewModel.set( "plate.width", xhr.data?.width ?? 1200 );
                        viewModel.set( "plate.height", xhr.data?.height ?? 500 );
                        viewModel.set( "plate.orientation", xhr.data.orientation );
                        viewModel.set( "plate.cellOrientation", xhr.data.cellOrientation );
                        viewModel.set( "plate.grid", xhr.data.grid );

                        viewModel.set( "plate.image", image ); // by product
                        viewModel.set( "plate.grid", xhr.data.grid );

                        viewModel.configPlate();

                    }
                }
            } );

        },

        firstLoadProductItems: function( type ) {
            const quotationItemId = viewModel.get( "detailForm.data.id" );
            const productId = viewModel.get( "detailForm.data.product.id" );

            console.log( "firstLoadProductItems" );

            // Chiamata AJAX iniziale per ottenere tutti i product items
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/product-items?productId=" + productId,
                callback: {
                    done: function( xhr ) {

                        var userItems = AP.getUserPref( "plate.product.items" );

                        if ( xhr.count > 0 ) {
                            /*
                            if ( !viewModel.get( "detailForm.data.product.image" ) && xhr.data[0].horizontalImage ) {
                                viewModel.set( "detailForm.data.product.image", xhr.data[0].horizontalImage );
                                viewModel.set( "backgroundImage", xhr.data[0].horizontalImage );
                                viewModel.set( "backgroundImage.url", "url('" + xhr.data[0].horizontalImage.uri + "')" );
                            }
                            if ( quotationItemId != "" || !userItems || userItems.length == 0 ) {
                                viewModel.set( "detailForm.data.product.items", new kendo.data.DataSource() );
                            } else {
                                if ( quotationItemId == "" ) {
                                    const itemsDataSource = new kendo.data.DataSource( {
                                        data: userItems
                                    } );
                                    viewModel.set( "detailForm.data.product.items", itemsDataSource );
                                    viewModel.get( "detailForm.data.product.items" ).read();
                                    viewModel.renderProductPreview( viewModel.get( "detailForm.data.product.items" ) );
                                }
                            }
                            */

                            var productItems = viewModel.get( "detailForm.data.product.items" );

                            var attributeArray = productItems.data();

                            // settiamo nel viewModel tutte le select di level 0 e le popoliamo con tutte le options
                            xhr.data.forEach( item => {
                                const existing = attributeArray.find( d => d.attributeId === item.attribute.id );
                                if ( existing ) {
                                    if ( !existing.values.find( v => v.productItemId === item.id ) ) {

                                        existing.values.push( {
                                            attributeValue: item.attributeValue,
                                            productItemId: item.id,
                                            // parentAttributeId: null,
                                            selected: false
                                        } );

                                        productItems.trigger( "change" );
                                    }
                                } else {

                                    const parsedData = {
                                        attributeId: item.attribute.id,
                                        attributeName: item.attribute.name,
                                        // parentAttributeId: null,
                                        level: 0,
                                        values: [
                                            {
                                                attributeValue: item.attributeValue,
                                                productItemId: item.id,
                                                selected: false
                                            }
                                        ]
                                    };

                                    productItems.add( parsedData );
                                }
                            } );

                            viewModel.renderProductItemsPlate();

                            setTimeout( function() {

                                viewModel.loadPlate();

                            }, 500 );

                        }
                    }
                }
            } ).then( async function() {
                // Se ci sono quotation items pre-selezionati, li carichiamo
                if ( quotationItemId != "" ) {
                    await NM.util.ajax( {
                        method: "GET",
                        url: "/manager/ajax/quotation-items/" + quotationItemId + "/product-items",
                        callback: {
                            done: async function( xhr ) {
                                xhr.data.sort( ( a, b ) => a.productItem.orderby - b.productItem.orderby );
                                if ( xhr.data.length > 0 ) {
                                    for ( const qipi of xhr.data ) {
                                        const select = $( `select[data-attribute-id="${qipi.productItem.attribute.id}"]` );
                                        if ( select.length > 0 ) {
                                            select.val( qipi.productItem.id );
                                            // Carichiamo eventuali figli ricorsivamente
                                            await viewModel.loadProductItems( qipi.productItem.id, qipi.productItem.attribute.id );
                                        }
                                    }
                                }
                            }
                        }
                    } );
                }
            } );
        },

        loadProductItems: function( originId, attributeId, fruitId ) {

            if ( fruitId == undefined ) {
                var type = "plate";
                var productId = viewModel.get( "detailForm.data.product.id" );
                var productItems = viewModel.get( "detailForm.data.product.items" );
            } else {
                var type = "fruit";
                var fruits = viewModel.get( "detailForm.data.fruits" );
                var fruit = fruits.get( fruitId );

                var productId = fruit.get( "id" );
                var productItems = fruit.get( "items" );
            }

            // console.log( "loadProductItems:type", type );
            // console.log( "productId", productId );
            // console.log( "originId", originId );

            const attributeArray = productItems.data();

            var originId = originId || "";

            let url = "/manager/ajax/product-items?productId=" + productId;

            // TODO: check if they are not all with the originId
            if ( originId ) {
                url += "&originId=" + originId;
            }

            // Deselezionamento: originId vuoto
            if ( originId === "" ) {

                // console.log( "qui:originId vuoto" );

                var actualIndex = null;

                for ( let i = attributeArray.length - 1; i >= 0; i-- ) {
                    if ( attributeArray[i].attributeId === attributeId ) {
                        actualIndex = i;
                        attributeArray[i].values.forEach( attrValue => attrValue.selected = false );
                    }
                }

                // Rimuovo attributi figli
                const i = actualIndex + 1;

                while ( i < attributeArray.length ) {
                    if ( attributeArray[i].level > attributeArray[actualIndex].level ) {
                        productItems.remove( attributeArray[i] );
                    } else {
                        break;
                    }
                }

                viewModel.renderProductItemsPlate();

                return;
            }

            // Selezionamento: originId valorizzato
            NM.util.ajax( {
                method: "GET",
                url: url,
                callback: {
                    done: function( xhr ) {
                        if ( xhr.data.length > 0 ) {

                            let attribute = null;
                            let toInsert = false;
                            let parentIndex = -1;

                            // Trovo l'indice dell'attributo selezionato
                            attributeArray.forEach( ( d, idx ) => {
                                if ( d.attributeId == attributeId ) { parentIndex = idx; }
                            } );

                            // Rimuovo eventuali attributi figli
                            const i = parentIndex + 1;

                            while ( i < attributeArray.length ) {
                                if ( attributeArray[ i ].level > attributeArray[ parentIndex ].level ) {
                                    productItems.remove( attributeArray[ i ] );
                                } else {
                                    break;
                                }
                            }

                            // Creo nuovo attributo se necessario
                            if ( !attribute ) {
                                attribute = {
                                    attributeId: xhr.data[0].attribute.id,
                                    attributeName: xhr.data[0].attribute.name,
                                    // parentAttributeId: attributeId,
                                    level: attributeArray[ parentIndex ].level + 1,
                                    values: []
                                };
                                toInsert = true;
                            }

                            // Imposto selected sul parent
                            if ( parentIndex !== -1 ) {
                                const parent = productItems.at( parentIndex );
                                parent.get( "values" ).forEach( v => {
                                    v.selected = v.productItemId == originId;
                                } );
                            }

                            // Popolo i valori del nuovo attributo
                            xhr.data.forEach( function( item ) {
                                attribute.values.push( {
                                    attributeValue: item.attributeValue,
                                    productItemId: item.id,
                                    selected: false
                                } );
                            } );

                            // Inserisco attributo se nuovo
                            if ( toInsert ) {
                                productItems.insert( parentIndex + 1, attribute );
                            }
                        } else {
                            // Se non ci sono figli, setto selected sul parent
                            let parentIndex = -1;
                            attributeArray.forEach( ( d, idx ) => {
                                if ( d.attributeId == attributeId ) {
                                    parentIndex = idx;
                                }
                            } );

                            if ( parentIndex !== -1 ) {
                                const parent = productItems.at( parentIndex );
                                parent.get( "values" ).forEach( v => {
                                    v.selected = v.productItemId == originId;
                                } );
                            }
                        }

                        // console.log( "loadProductItems:afterLoading:type", type );

                        if ( type == "plate" ) {
                            viewModel.renderProductItemsPlate();
                        } else {
                            viewModel.renderProductItemsFruit( productId );
                        }

                    },
                }
            } );

        },

        loadProduct() {

            var lineId   = viewModel.get( "detailForm.data.product.line.id" );
            var modelId  = viewModel.get( "detailForm.data.product.model.id" );
            var finishId = viewModel.get( "detailForm.data.product.finish.id" );

            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotation-items/product/by-params" +
                        "?categoryId=22" +
                        "&lineId=" + lineId +
                        "&modelId=" + modelId +
                        "&finishId=" + finishId,
                callback: {
                    done: function( xhr ) {

                        viewModel.set( "detailForm.data.product.id", xhr.data.id );
                        viewModel.set( "detailForm.data.product.finish.id", xhr.data.finish.id );
                        viewModel.set( "detailForm.data.product.model.id", xhr.data.model.id );
                        viewModel.set( "detailForm.data.product.model.code", xhr.data.model.code ); // for frame
                        viewModel.set( "detailForm.data.product.line.id", xhr.data.line.id );
                        viewModel.set( "detailForm.data.product.image.id", xhr.data.horizontalImage.id );
                        viewModel.set( "detailForm.data.product.image.uri", xhr.data.horizontalImage.uri );

                        // set items
                        viewModel.firstLoadProductItems();

                    }
                }
            } );

        },

        addProductItemsToFruit: function( fruitId ) {

            var fruits = viewModel.get( "detailForm.data.fruits" );
            var thisFruit = fruits.get( fruitId );
            var productId = thisFruit.fruit.id;

            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/product-items?productId=" + productId,
                callback: {
                    done: function( xhr ) {

                        if ( xhr.count > 0 ) {

                            var thisImage = xhr.data[0].horizontalImage;

                            // Overwrite the product image if the item image exists
                            if ( thisImage ) {
                                thisFruit.set( "fruit.horizontalImage", thisImage );
                                pub.fruitsController.updateFruit( thisFruit.id, { image:  thisImage.uri } );
                            }

                            var fruitItems = thisFruit.get( "items" );
                            var attributeArray = fruitItems.data();

                            xhr.data.forEach( function( item ) {

                                const attributeExisting = attributeArray.find( d => d.attributeId === item.attribute.id );

                                if ( attributeExisting ) {

                                    attributeExisting.values.push( {
                                        attributeValue: item.attributeValue,
                                        productItemId: item.id,
                                        selected: false
                                    } );

                                } else {

                                    const itemAndValues = {
                                        attributeId: item.attribute.id,
                                        attributeName: item.attribute.name,
                                        level: 0,
                                        values: [
                                            {
                                                attributeValue: item.attributeValue,
                                                productItemId: item.id,
                                                selected: false
                                            }
                                        ]
                                    };

                                    fruitItems.add( itemAndValues );

                                }

                            } );

                            console.log( "fruitItems", fruitItems );

                            thisFruit.set( "items", fruitItems );

                            viewModel.renderProductItemsFruit( fruitId );

                        }
                    }
                }
            } ).then( async function() {
                // Se ci sono quotation items pre-selezionati, li carichiamo
                if ( quotationItemId != "" ) {
                    await NM.util.ajax( {
                        method: "GET",
                        url: "/manager/ajax/quotation-items/" + quotationItemId + "/product-items",
                        callback: {
                            done: async function( xhr ) {
                                xhr.data.sort( ( a, b ) => a.productItem.orderby - b.productItem.orderby );
                                if ( xhr.data.length > 0 ) {
                                    for ( const qipi of xhr.data ) {
                                        const select = $( `select[data-attribute-id="${qipi.productItem.attribute.id}"]` );
                                        if ( select.length > 0 ) {
                                            select.val( qipi.productItem.id );
                                            // Carichiamo eventuali figli ricorsivamente
                                            await viewModel.loadProductItems( qipi.productItem.id, qipi.productItem.attribute.id );
                                        }
                                    }
                                }
                            }
                        }
                    } );
                }
            } );

        },

        renderProductItemsFruit: function( fruitId ) {
            const container = $( "#quotation-fruit-row-items_" + fruitId );

            container.empty();

            // console.log( "fruit:container:id", fruitId );
            // console.log( "fruit:container", container );

            var fruits = viewModel.get( "detailForm.data.fruits" );
            var fruit = fruits.get( fruitId );

            const attributeArray = fruit.get( "items" ).data();

            // console.log( "fruit:attributeArray", fruitId, attributeArray );

            attributeArray.forEach( function( item ) {

                var newLevel = ( 1.5 * item.level ) + "rem";

                // console.log( "renderProductItemsFruit:attributeArray:item", item );

                const attrName = item.attributeName;
                const values = item.values;

                const subContainer = $( "<div>" );
                subContainer.attr( "id", "fruit-attribute-container-" + item.attributeId );
                container.append( subContainer );

                const label = $( "<label>" );

                label.addClass( "mb-1" );
                label.css( "margin-left", newLevel );
                label.text( item.level + " " + attrName );
                subContainer.append( label );

                const select = $( "<select>" ).addClass( "form-control me-3 mb-2" ).on( "change", function() {
                    const selectedId = $( this ).val();
                    const attributeId = $( this ).data( "attribute-id" );
                    viewModel.loadProductItems( selectedId, attributeId, fruitId );
                } );

                select.attr( "data-attribute-id", item.attributeId );

                if ( item.level > 0 ) {
                    select.css( "margin-left", newLevel );
                    select.css( "width", `calc(100% - ${1.5 * item.level}rem)` );
                }

                values.forEach( function( attrValue ) {
                    const option = $( "<option>" )
                        .val( attrValue.productItemId )
                        .html( `<b>${attrName}</b> ${attrValue.attributeValue.rawValue.name}` );
                    select.append( option );
                } );

                // Imposto la option selezionata
                const selectedOption = values.find( attrValue => attrValue.selected === true );
                if ( selectedOption ) {
                    if ( selectedOption ) {
                        select.val( selectedOption.productItemId );
                    }
                } else {
                    select.prop( "selectedIndex", 0 ).trigger( "change" );
                }

                subContainer.append( select );
            } );
        },

        renderProductItemsPlate: function() {
            const container = $( "#quotation-plate-product-items" );
            container.empty();

            const productItems = viewModel.get( "detailForm.data.product.items" );
            const attributeArray = productItems.data();

            attributeArray.forEach( function( item ) {
                const attrName = item.attributeName;
                const values = item.values;

                const subContainer = $( "<div>" );
                subContainer.attr( "id", "attribute-container-" + item.attributeId );
                container.append( subContainer );

                const label = $( "<label>" );
                label.addClass( "mb-1" );
                label.css( "margin-left", ( 1.5 * item.level ) + "rem" );
                label.text( item.level + " " + attrName );
                subContainer.append( label );

                const select = $( "<select>" ).addClass( "form-control me-3 mb-2" ).on( "change", function() {
                    const selectedId = $( this ).val();
                    const attributeId = $( this ).data( "attribute-id" );
                    viewModel.loadProductItems( selectedId, attributeId );
                } );

                select.attr( "data-attribute-id", item.attributeId );

                if ( item.level > 0 ) {
                    select.css( "margin-left", ( 1.5 * item.level ) + "rem" );
                    select.css( "width", `calc(100% - ${1.5 * item.level}rem)` );
                }

                // const emptyOption = $( "<option>" ).val( "" ).html( "-- Seleziona valore attributo" );
                // select.append( emptyOption );

                values.forEach( function( attrValue ) {
                    const option = $( "<option>" )
                        .val( attrValue.productItemId )
                        .html( `<b>${attrName}</b> ${attrValue.attributeValue.rawValue.name}` );
                    select.append( option );
                } );

                // Imposto la option selezionata
                const selectedOption = values.find( attrValue => attrValue.selected === true );

                if ( selectedOption ) {
                    if ( selectedOption ) {
                        select.val( selectedOption.productItemId );
                    }
                } else {
                    select.prop( "selectedIndex", 0 ).trigger( "change" );
                }

                subContainer.append( select );
            } );
        },

        loadLines: function( event ) {
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/lines/22",
                callback: {
                    done: function( xhr ) {

                        viewModel.get( "lines" ).data( xhr.data );

                        // viewModel.set( "detailForm.data.product.catalogBundle.line", xhr.data[0] );

                        NM.util.openModal( AP.plate.fields.modalRoot );
                    },
                },
            } );
        },

        loadModels: function( event ) {

            var lineId = viewModel.get( "detailForm.data.product.line.id" );

            // console.log( "loadModels:line.id", lineId );

            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/models/" + lineId,
                callback: {
                    done: function( xhr ) {
                        // console.log( "loadModels" );
                        viewModel.get( "models" ).data( xhr.data );
                        // viewModel.set( "detailForm.data.product.catalogBundle.model.id", xhr.data[0] );

                    },
                },
            } );
        },

        loadFinishes: function( event ) {

            var lineId = viewModel.get( "detailForm.data.product.line.id" );

            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/finishes/22/" + lineId,
                callback: {
                    done: function( xhr ) {

                        // console.log( "loadFinishes" );
                        viewModel.get( "finishes" ).data( xhr.data );

                    },
                },
            } );
        },

        resetForm: function() {},

        save: function() {

            const parsedData = viewModel.get( "detailForm.data" );
            var status = fields.modalRoot.find( ".save-status" );

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            parsedData.quotationId = AP.page.quotation.id;
            parsedData.type = "plate";

            var preview = $( "#plate-background" )[0];

            html2canvas( preview, { useCORS: true } ).then( function( canvas ) {
                const imgData = canvas.toDataURL( "image/png" ).replace( /^data:image\/png;base64,/, "" );
                parsedData.imageBase64 = imgData;
                parsedData.price = AP.quotation.pricing.getData().data;

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/quotation-items/plate",
                    data: JSON.stringify( parsedData ),
                    callback: {
                        done: function( xhr ) {
                            status.html( "" );
                            AP.widget.notify( "success", "Placca salvata correttamente." );
                            viewModel.set( "detailForm", defaultDetailForm );
                            setTimeout( () => window.location.reload(), 1000 );
                        }
                    }
                } );
            } );

            return false;
        },

        onSelectFruit: function( selectedFruit ) {

            var newFruit = createFruit( { position: 1, fruit: selectedFruit } );

            viewModel.set( "currentFruit", newFruit );
            viewModel.get( "detailForm.data.fruits" ).add( newFruit );

            pub.fruitsController.addFruitToPlate( mapFruitForPlate( newFruit ) );

            viewModel.addProductItemsToFruit( newFruit.id );

        },

        configPlate: function() {

            // var plate = this.plates.get( this.get( "plate" ) );
            var plate = this.get( "plate" );

            FREE_CELL_WIDTH = constants.GRID_CELL_DIMENSIONS[ CELL_TYPE.FREE ].width;
            FREE_CELL_HEIGHT = constants.GRID_CELL_DIMENSIONS[ CELL_TYPE.FREE ].height;

            if ( plate.orientationCell == orientation.VERTICAL ) {
                const tmp = FREE_CELL_WIDTH;
                FREE_CELL_WIDTH = FREE_CELL_HEIGHT;
                FREE_CELL_HEIGHT = tmp;
            }

            const grid = [];

            // create grid
            for ( let iRow = 0; iRow < plate.grid.length; iRow++ ) {
                const row = [];

                for (
                    let iCol = 0;
                    iCol < plate.grid[ iRow ].length;
                    iCol++
                ) {
                    const cellType = plate.grid[ iRow ][ iCol ];

                    const cell = new Cell(
                        constants.GRID_CELL_DIMENSIONS[ cellType ].width,
                        constants.GRID_CELL_DIMENSIONS[ cellType ].height,
                        plate.orientationCell.id,
                        cellType,
                    );

                    row.push( cell );
                }

                grid.push( row );
            }

            const plateObj = new Plate( {
                width: plate.width,
                height: plate.height,
                orientation: plate.orientation.id,
                cellOrientation: plate.orientationCell.id,
                id: plate.id,
                code: plate.code,
                image: plate.image.uri,
                grid: grid,
                isSpecial: false,
            } );

            // console.log( "fruits:fruitList", fruitList );

            pub.fruitsController = new FruitsController( {
                plate: plateObj,
                fruits: [],
            } );

            pub.fruitsController.plate.drawGridWithin( $( ".plate-designer" ) );

            // se ci sono frutti li reinserisco
            // var fruitList = [];

            var fruits = viewModel.get( "detailForm.data.fruits" );

            if ( fruits.total() ) {
                for ( var thisFruit of fruits.data() ) {
                    var obj = mapFruitForPlate( thisFruit );
                    pub.fruitsController.addFruitToPlate( obj );
                };
            }

        },
    } );

    pub.new = function( onSave ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.set( "detailForm.data.quotationZone", AP.quotation.detail.config().zone );

        viewModel.loadLines();

    };

    var initFruitsSuggest = function() {

        var suggest = $( "#plate-fruit-suggest" );
        var autocomplete = suggest.data( "kendoAutoComplete" );
        var suggestTemplate = $( "#quotation-fruit-suggest-row-tmpl" ).html();

        if ( autocomplete ) {
            return;
        }

        suggest.keypress( function( event ) {
            if( event.keyCode == 13 ){
                return false;
            }
        } );

        suggest.kendoAutoComplete( {
            template: $.proxy( kendo.template( suggestTemplate ) ),
            dataTextField: "term",
            highlightFirst: true,
            minLength: 3,
            dataSource: new kendo.data.DataSource( {
                serverFiltering: true,
                transport: {
                    read: {
                        url: "/manager/ajax/fruits",
                        data: {
                            str: function() {
                                return suggest.data( "kendoAutoComplete" ).value();
                            },
                        },
                    },
                    parameterMap : function( data, type ) {
                        if ( type === "read" ) {
                            return { "str": data.str() };
                        }
                    }
                },
                schema: {
                    data: function( xhr ) {
                        return xhr.data;
                    }
                },
            } ),
            select: function( event ) {
                var item = this.dataItem( event.item.index() );

                // console.log( "selected fruit", item );

                viewModel.onSelectFruit( item );
            },
            noDataTemplate: "<div>NESSUN RECORD</div>"
        } );

    };

    pub.init = function( setup ) {

        settings.container = setup.container;

        initFruitsSuggest();

        kendo.bind( settings.container, viewModel );
    };

    pub.getVM = function() {
        return viewModel;
    };

    return pub;
} () );
