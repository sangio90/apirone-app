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

                    console.log("cell.height", cell.height)
                    console.log("cell.width", cell.width)

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

            console.log("Fruit:orientation", orientation.VERTICAL);
            console.log("this.orientation", this.orientation);

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
            
            console.log("drawWithin:imgCSS", imgCSS);
            console.log("drawWithin:this.orientation", this.orientation);
            console.log("drawWithin:orientation.VERTICAL", orientation.VERTICAL);

            //console.log("Fruit:drawWithin:this.orientation", orientation.VERTICAL);
            //console.log("Fruit:drawWithin:this.orientation", this.orientation);

            if ( this.orientation == orientation.VERTICAL ) {
                console.log("drawWithin:rotated");
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

            console.log("FruitsController initialized", args.plate);

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
            
            console.log( "addFruitToPlate:this.plate.orientation", this.plate.orientation );

            const fruitObj = new Fruit( {
                width: selectedFruit.width,
                height: selectedFruit.height,
                rowSpan: selectedFruit.rowSpan,
                columnSpan: selectedFruit.columnSpan,
                orientation: this.plate.orientation,
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
