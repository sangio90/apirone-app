AP.plate = AP.plate || {};

AP.plate.fields = {
	designerRoot: $("#plate-designer-root"),
	mapRoot: $("#plate-map-root"),
};

$(document).ready(function () {
	if (AP.plate.fields.designerRoot.length) {
		AP.plate.designer.init({
			container: AP.plate.fields.designerRoot,
		});
	}

	if (AP.plate.fields.mapRoot.length) {
		AP.plate.map.init({
			container: AP.plate.fields.mapRoot,
		});
	}
});

AP.plate.designer = (function () {
	let FREE_CELL_WIDTH;
	let FREE_CELL_HEIGHT;

	const MIN_DISTANCE_BEFORE_DRAGGING = 1;

	const ORIENTATION = {
		VERTICAL: "V",
		HORIZONTAL: "H",
		"V": "VERTICAL",
		"H": "HORIZONTAL",
	};

	const CELL_TYPE = {
		FREE: "_",
		PROHIBITED: "0",
		"_": "FREE",
		"0": "PROHIBITED",
	};

	const MOVE_DIRECTION = {
		LEFT: 1,
		RIGHT: 2,
		TOP: 4,
		BOTTOM: 8,
	};

	const utils = {
		convertAbsolutePositionToGridPosition(ui, fruitPosition) {
			let newPositionDirection = 0;
			const deltaLeft = Math.sign(ui.position.left - ui.originalPosition.left);
			if (deltaLeft > 0) {
				newPositionDirection |= MOVE_DIRECTION.RIGHT;
			} else if (deltaLeft < 0) {
				newPositionDirection |= MOVE_DIRECTION.LEFT;
			}

			const deltaTop = Math.sign(ui.position.top - ui.originalPosition.top);
			if (deltaTop > 0) {
				newPositionDirection |= MOVE_DIRECTION.BOTTOM;
			} else if (deltaTop < 0) {
				newPositionDirection |= MOVE_DIRECTION.TOP;
			}

			const fruitsController = AP.plate.designer.fruitsController;
			const grid = fruitsController.plate.grid;

			const result = {
				row: null,
				column: null,
			};

			for (let row = 0; row < grid.length; row++) {
				for (let column = 0; column < grid[row].length; column++) {
					const cell = grid[row][column];

					if ((newPositionDirection & MOVE_DIRECTION.RIGHT) == MOVE_DIRECTION.RIGHT) {
						if (cell.left <= fruitPosition.right && fruitPosition.right <= cell.right) {
							const fruitWidth = Math.abs(fruitPosition.left - fruitPosition.right);

							result.column = (column - (fruitWidth / FREE_CELL_WIDTH)) + 1;
						}
					} else if ((newPositionDirection & MOVE_DIRECTION.LEFT) == MOVE_DIRECTION.LEFT) {
						if (cell.left <= fruitPosition.left && fruitPosition.left <= cell.right) {
							result.column = column;
						}
					} else { // STILL
						if (cell.left <= fruitPosition.left && fruitPosition.left <= cell.right) {
							result.column = column;
						}
					}

					if ((newPositionDirection & MOVE_DIRECTION.BOTTOM) == MOVE_DIRECTION.BOTTOM) {
						if (cell.top <= fruitPosition.bottom && fruitPosition.bottom <= cell.bottom) {
							const fruitHeight = Math.abs(fruitPosition.top - fruitPosition.bottom);

							result.row = (row - (fruitHeight / FREE_CELL_HEIGHT)) + 1;
						}
					} else if ((newPositionDirection & MOVE_DIRECTION.TOP) == MOVE_DIRECTION.TOP) {
						if (cell.top <= fruitPosition.top && fruitPosition.top <= cell.bottom) {
							result.row = row;
						}
					} else { // STILL
						if (cell.top <= fruitPosition.top && fruitPosition.top <= cell.bottom) {
							result.row = row;
						}
					}
				}
			}

			return result;
		},
		doRectanglesCollide(rectA, rectB) {
			let result = true;

			if (
				rectA.right <= rectB.left
				|| rectA.left >= rectB.right
				|| rectA.bottom <= rectB.top
				|| rectA.top >= rectB.bottom
			) {
				result = false;
			}

			return result;
		},
		extractTopLeftPositionFrom(gridPosition) {
			const result = {
				top: null,
				left: null,
			};

			const fruitsController = AP.plate.designer.fruitsController;
			const grid = fruitsController.plate.grid;

			const cell = grid[gridPosition.row][gridPosition.column];

			result.top = cell.top;
			result.left = cell.left;

			return result;
		},
		findFirstFreePosition(fruit) {
			const result = {
				row: null,
				column: null,
			};

			const fruitsController = AP.plate.designer.fruitsController;
			const grid = fruitsController.plate.grid;

			for (let y = 0; y < grid.length; y++) {
				const row = grid[y];

				let columnCount = 0;
				for (let x = 0; x < row.length; x++) {
					const cell = row[x];
					const cellHasFruit = utils.cellHasFruit(y, x);

					if (cell.type == CELL_TYPE.PROHIBITED || cellHasFruit) {
						columnCount = 0;
					} else {
						columnCount++;
					}

					if (columnCount == fruit.columnSpan) {
						result.row = y;
						result.column = x - columnCount + 1;

						return result;
					}
				}
			}

			return result;
		},
		cellHasFruit(row, column) {
			let result = false;

			const fruitsController = AP.plate.designer.fruitsController;
			const fruits = fruitsController.fruits;

			for (const fruit of fruits) {
				const fruitPosition = fruit.gridPosition;

				if (
					fruitPosition.column <= column && column <= fruitPosition.column + fruit.columnSpan - 1
					&& fruitPosition.row <= row && row <= fruitPosition.row + fruit.rowSpan - 1
				) {
					result = true;

					break;
				}
			}

			return result;
		},
	};

	class FruitGridPosition {
		constructor(
			row,
			column,
		) {
			this.row = row;
			this.column = column;
		}
	}

	class Rectangle {
		constructor(
			width,
			height,
			orientation
		) {
			this.orientation = orientation;
			this.width = orientation == ORIENTATION.VERTICAL ? height : width;
			this.height = orientation == ORIENTATION.VERTICAL ? width : height;

			this._$element = null;

			this._top = null;
			this._bottom = null;
			this._left = null;
			this._right = null;
		}

		get $element() {
			return this._$element;
		}

		set $element(value) {
			this._$element = value;
		}

		get top() {
			return this._top;
		}

		set top(value) {
			this._top = value;

			this._bottom = this._top + this.height;
		}

		get bottom() {
			return this._bottom;
		}

		get left() {
			return this._left;
		}

		set left(value) {
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
		constructor(args) {
			super(args.width, args.height, args.orientation);

			this.uuid = args.uuid;
			this.code = args.code;
			this.img = args.img;
			this.grid = args.grid;
			this.isSpecial = args.isSpecial;
			this.cellOrientation = args.cellOrientation;
		}

		/**
		 * Creates HTML nodes and inserts them in the DOM to visualize grid property
		 */
		drawGridWithin($rootNode) {
			$rootNode.empty();

			const $plateBackground = $("<div/>", {
				"class": "plate-background",
				"css": {
					"width": `${this.width}px`,
					"height": `${this.height}px`,
					"background-image": `url('${this.img}')`,
				},
				"appendTo": $rootNode
			});

			const platePosition = $plateBackground.position();

			this.top = platePosition.top;
			this.left = platePosition.left;

			const $plateLayers = $("<div/>", {
				"id": "plate-layers",
				"appendTo": $plateBackground
			});

			const plateCSS = {
				"grid-template-rows": "",
				"grid-template-columns": "",
			};

			const gridTemplateRows = [];
			const gridTemplateColumns = [];

			for (let i = 0; i < this.grid.length; i++) {
				gridTemplateRows.push(0);
			}

			for (let i = 0; i < this.grid[0].length; i++) {
				gridTemplateColumns.push(0);
			}

			for (let i = 0; i < this.grid.length; i++) {
				const row = this.grid[i];

				const maxCellHeight = Math.max(...row.map(x => x.height));

				gridTemplateRows[i] = maxCellHeight;
			}

			for (let i = 0; i < this.grid[0].length; i++) {
				const cells = [];

				for (let j = 0; j < this.grid.length; j++) {
					const cell = this.grid[j][i];

					cells.push(cell);
				}

				const minCellWidth = Math.min(...cells.map(x => x.width));

				gridTemplateColumns[i] = minCellWidth;
			}

			plateCSS["grid-template-rows"] = gridTemplateRows.map(x => `${x}px`).join(" ");
			plateCSS["grid-template-columns"] = gridTemplateColumns.map(x => `${x}px`).join(" ");

			const $plateGrid = $("<div/>", {
				"id": "plate-grid",
				"css": plateCSS,
				"appendTo": $plateLayers
			});

			const $fruits = $("<div/>", {
				"id": "fruits",
				"appendTo": $plateLayers
			});

			for (let y = 1; y <= this.grid.length; y++) {
				const row = this.grid[y - 1];

				for (let x = 1; x <= row.length; x++) {
					const cell = row[x - 1];

					const $plateCell = $("<div/>", {
						"class": `grid-column p${x} ${cell.type == CELL_TYPE.PROHIBITED ? "prohibited" : ""}`,
						"css": {
							"grid-row": `${y} / ${y + 1}`,
							"grid-column": `${x} / ${x + 1}`,
						},
						"appendTo": $plateGrid,
					});

					cell.$element = $plateCell;

					if (cell.type != CELL_TYPE.PROHIBITED) {
						const $cellLabel = $("<span/>", {
							"text": `(${x}, ${y})`,
							"class": "position-label",
							"css": {
								"font-size": "8px",
							},
							"appendTo": $plateCell,
						});
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
		constructor(width, height, orientation, type) {
			super(width, height, orientation);

			this.type = type;
			this._position = null;
		}

		get position() {
			return this._position;
		}

		set position(position) {
			this._position = position;
		}

		setIsOverlapped(value) {
			if (value) {
				this.$element.addClass("overlapped");
			} else {
				this.$element.removeClass("overlapped");
			}
		}

		setIfOverlappedBy(fruitPosition) {
			const cellRectangle = {
				top: this.top,
				bottom: this.bottom,
				left: this.left,
				right: this.right,
			};

			this.setIsOverlapped(utils.doRectanglesCollide(fruitPosition, cellRectangle));
		}
	}

	class Fruit extends Rectangle {
		constructor(args) {
			super(args.width, args.height, args.orientation);

			this.rowSpan = this.orientation == ORIENTATION.VERTICAL ? args.columnSpan : args.rowSpan;
			this.columnSpan = this.orientation == ORIENTATION.VERTICAL ? args.rowSpan : args.columnSpan;

			this.uuid = args.uuid;
			this.code = args.code;
			this.name = args.name;
			this.img = args.img;

			this._gridPosition = null;
			this._originalGridPosition = null;
		}

		get gridPosition() {
			return this._gridPosition;
		}

		set gridPosition(value) {
			this._gridPosition = value;

			if (Math.sign(this._gridPosition.row) >= 0 && Math.sign(this._gridPosition.column) >= 0) {
				const { top, left } = utils.extractTopLeftPositionFrom(this._gridPosition);

				this.top = top;
				this.left = left;
			}
		}

		initDraggableWidget(controller) {
			const self = this;

			self._$element.draggable({
				containment: "#fruits",
				distance: MIN_DISTANCE_BEFORE_DRAGGING,
				// grid: [ATOMIC_WIDTH],
				revertDuration: 250,
				start: function (event, ui) {
					controller.onStartDragging(self, event, ui);
				},
				drag: function (event, ui) {
					controller.onDragging(self, event, ui);
				},
				stop: function (event, ui) {
					controller.onStopDragging(self, event, ui);
				},
			});
		}

		isOverlappingWith(otherFruit) {
			let result = true;

			const x5 = Math.max(this.left, otherFruit.left);
			const x6 = Math.min(this.left + this.width, otherFruit.left + otherFruit.width);

			const y5 = Math.max(this.top, otherFruit.top);
			const y6 = Math.min(this.top + this.height, otherFruit.top + otherFruit.height);

			if (x5 >= x6) {
				result = false;
			}

			if (y5 >= y6) {
				result = false;
			}

			return result;
		}

		canSwapWith(otherFruit) {
			// Only if both are in the same position and are of equal size
			return this.gridPosition.row == otherFruit.gridPosition.row
				&& this.gridPosition.column == otherFruit.gridPosition.column
				&& this.top + this.height == otherFruit.top + otherFruit.height
				&& this.left + this.width == otherFruit.left + otherFruit.width;
		}

		swapPositionWith(otherFruit) {
			this.gridPosition = otherFruit.gridPosition;
			otherFruit.gridPosition = this._originalGridPosition;
		}

		fitsWithin(containmentGrid) {
			const columnSpan = {
				start: this.gridPosition.column,
				end: this.gridPosition.column + (this.width / FREE_CELL_WIDTH),
			};

			const rowSpan = {
				start: this.gridPosition.row,
				end: this.gridPosition.row + (this.height / FREE_CELL_HEIGHT),
			};

			return 0 <= columnSpan.start && columnSpan.end <= containmentGrid[0].length
				&& 0 <= rowSpan.start && rowSpan.end <= containmentGrid.length;
		}

		/**
		 * Calculates a separation vector that moves the given overlapping Fruit away from this Fruit
		 * @param {Array} otherFruit
		 * @returns Array of two elements: [x, y]
		 */
		calculateSeparation(otherFruit) {
			const result = [0, 0];

			const thisCenterPoint = [
				this.left + (this.width / 2),
				this.top + (this.height / 2),
			];

			const otherCenterPoint = [
				otherFruit.left + (otherFruit.width / 2),
				otherFruit.top + (otherFruit.height / 2),
			];

			const separationVector = [
				otherCenterPoint[0] - thisCenterPoint[0],
				otherCenterPoint[1] - thisCenterPoint[1],
			];

			const vectorLength = Math.sqrt(Math.pow(separationVector[0], 2) + Math.pow(separationVector[1], 2)); // Pythagorean theorem

			if (vectorLength == 0) {
				return result; // Avoid division by zero
			}

			const normalizedVector = [separationVector[0] / vectorLength, separationVector[1] / vectorLength];

			const moveAmountX = FREE_CELL_WIDTH; // Adjust it on your needs
			const moveAmountY = FREE_CELL_HEIGHT; // Adjust it on your needs

			result[0] = normalizedVector[0] * moveAmountX;
			result[1] = normalizedVector[1] * moveAmountY;

			return result;
		}

		hasChangedPosition() {
			return this._originalGridPosition.column != this.gridPosition.column
				|| this._originalGridPosition.row != this.gridPosition.row;
		}

		makePositionSnapshot() {
			this._originalGridPosition = new FruitGridPosition(this.gridPosition.row, this.gridPosition.column);
		}

		restorePositionToLastSnapshot() {
			this.gridPosition = this._originalGridPosition;
		}

		startDragging() {
			this.$element.addClass("is-dragging");
		}

		stopDragging() {
			this.$element.removeClass("is-dragging");
		}

		onEnterInProhibitedPosition() {
			this.$element.addClass("is-in-prohibited-position");
		}

		onExitFromProhibitedPosition() {
			this.$element.removeClass("is-in-prohibited-position");
		}

		drawWithin($rootNode) {
			const $fruit = $("<div/>", {
				"id": this.uuid,
				"class": "draggable-fruit",
				"css": {
					"top": `${this.top}px`,
					"left": `${this.left}px`,
					"width": `${this.width}px`,
					"height": `${this.height}px`,
				},
				"appendTo": $rootNode,
			});

			const imgCSS = {
				"width": `${this.width}px`,
				"height": `${this.height}px`,
			};

			if (this.orientation == ORIENTATION.VERTICAL) {
				const tmp = imgCSS.width;
				imgCSS.width = imgCSS.height;
				imgCSS.height = tmp;

				if (this.isSquare()) {
					imgCSS.transform = "rotate(90deg)";
				} else {
					imgCSS.transform = "rotate(90deg) translate(-50%, 0%)";
				}
			}

			const $img = $("<img/>", {
				"src": this.img,
				"class": "fruit-img",
				"css": imgCSS,
				"appendTo": $fruit,
			});

			this.$element = $fruit;
		}

		/**
		 * Renders Fruit based on current position
		 */
		render() {
			this.$element.css({
				left: this.left,
				top: this.top,
			});
		}
	}

	class FruitsController {
		constructor(args) {
			this.plate = args.plate;
			this.fruits = args.fruits;
		}

		/**
		 *	Creates HTML nodes and inserts them in the DOM to visualize fruits on the grid
		 */
		drawFruitsWithin($rootNode) {
			for (const fruit of this.fruits) {
				fruit.drawWithin($rootNode);
			}
		}

		/**
		 * Initializes jQuery UI Draggable Widget for each fruit
		 */
		makeFruitsDraggable() {
			for (const fruit of this.fruits) {
				fruit.initDraggableWidget(this);
			}
		}

		restoreAllFruitPositions() {
			for (const fruit of this.fruits) {
				fruit.restorePositionToLastSnapshot();
			}
		}

		isFruitInProhibitedPosition(fruitRectangle) {
			let result = false;

			for (const row of this.plate.grid) {
				if (result) {
					break;
				}

				for (const cell of row) {
					if (cell.type == CELL_TYPE.PROHIBITED) {
						const cellRectangle = {
							top: cell.top,
							bottom: cell.top + cell.height,
							left: cell.left,
							right: cell.left + cell.width,
						};

						if (utils.doRectanglesCollide(fruitRectangle, cellRectangle)) {
							result = true;

							break;
						}
					}
				}
			}

			return result;
		}

		renderFruits() {
			for (const fruit of this.fruits) {
				fruit.render();
			}
		}

		hasOverlappedFruits() {
			return this.fruits.some(fruit => {
				return this.fruits.some(otherFruit => otherFruit != fruit ? fruit.isOverlappingWith(otherFruit) : false);
			});
		}

		moveAwayAllFruitsFrom(targetFruit) {
			let result = true;

			const filteredFruits = this.fruits.filter(f => f != targetFruit);

			const MAX_ITERATIONS = 1000;

			let counter = 0;
			while (this.hasOverlappedFruits()) {
				if (counter > MAX_ITERATIONS) {
					result = false;

					console.error("DANGER! Potential infinite loop.");

					return result;
				}

				const overlapVectors = [];

				for (const fruit of filteredFruits) {
					const vector = this.generateNormalizedOverlapVector(fruit);

					if (vector[0] != 0 || vector[1] != 0) {
						overlapVectors.push([fruit, vector]);
					}
				}

				for (const [fruit, vector] of overlapVectors) {
					const isSuccess = this.translateFruitByVector(fruit, vector);

					if (!isSuccess) {
						result = false;

						return result;
					}
				}

				counter++;
			}

			return result;
		}

		generateNormalizedOverlapVector(fruit) {
			const vector = [0, 0];

			const filteredFruits = this.fruits.filter(f => f != fruit);

			for (const otherFruit of filteredFruits) {
				if (fruit.isOverlappingWith(otherFruit)) {
					const innerVector = fruit.calculateSeparation(otherFruit);

					vector[0] += innerVector[0];
					vector[1] += innerVector[1];
				}
			}

			return vector;
		}

		translateFruitByVector(fruit, vector) {
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

			return !this.isFruitInProhibitedPosition(fruitRectangle)
				&& fruit.fitsWithin(this.plate.grid);
		}

		onSelectFruit(selectedFruit) {
			const fruitObj = new Fruit({
				width: selectedFruit.width,
				height: selectedFruit.height,
				rowSpan: selectedFruit.rowSpan,
				columnSpan: selectedFruit.columnSpan,
				orientation: this.plate.cellOrientation,
				uuid: selectedFruit.uuid,
				code: selectedFruit.code,
				name: selectedFruit.name,
				img: selectedFruit.img,
			});

			const freePosition = utils.findFirstFreePosition(fruitObj);

			if (freePosition.row != null && freePosition.column != null) {
				fruitObj.gridPosition = new FruitGridPosition(freePosition.row, freePosition.column);

				this.fruits.push(fruitObj);

				fruitObj.drawWithin($("#fruits"));
				fruitObj.initDraggableWidget(this);
			}
		}

		/**
		 * Triggered when dragging starts
		 * @param {Fruit} fruit
		 * @param {Event} event
		 * @param {object} ui
		 */
		onStartDragging(fruit, event, ui) {
			fruit.startDragging();

			for (const fruit of this.fruits) {
				fruit.makePositionSnapshot();
			}
		}

		/**
		 * Triggered while the mouse is moved during the dragging, immediately before the current move happens.
		 * @param {Fruit} fruit
		 * @param {Event} event
		 * @param {object} ui The values may be changed to modify where the element will be positioned. This is useful for custom containment, snapping, etc
		 */
		onDragging(fruit, event, ui) {
			let newFruitPosition = {
				top: ui.position.top,
				bottom: ui.position.top + fruit.height,
				left: ui.position.left,
				right: ui.position.left + fruit.width,
			};

			const { row, column } = utils.convertAbsolutePositionToGridPosition(ui, newFruitPosition);
			const gridPosition = new FruitGridPosition(row, column);
			const { top, left } = utils.extractTopLeftPositionFrom(gridPosition);
			newFruitPosition = {
				top: top,
				bottom: top + fruit.height,
				left: left,
				right: left + fruit.width,
			};

			for (const row of this.plate.grid) {
				for (const cell of row) {
					cell.setIfOverlappedBy(newFruitPosition);
				}
			}

			if (this.isFruitInProhibitedPosition(newFruitPosition)) {
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
		onStopDragging(fruit, event, ui) {
			for (const row of this.plate.grid) {
				for (const cell of row) {
					cell.setIsOverlapped(false);
				}
			}

			const newFruitPosition = {
				top: ui.position.top,
				bottom: ui.position.top + fruit.height,
				left: ui.position.left,
				right: ui.position.left + fruit.width,
			};

			const { row, column } = utils.convertAbsolutePositionToGridPosition(ui, newFruitPosition);
			fruit.gridPosition = new FruitGridPosition(row, column);

			const fruitPosition = {
				top: fruit.top,
				bottom: fruit.bottom,
				left: fruit.left,
				right: fruit.right,
			};

			if (this.isFruitInProhibitedPosition(fruitPosition)) {
				fruit.restorePositionToLastSnapshot();
			} else {
				if (fruit.hasChangedPosition()) {
					if (this.hasOverlappedFruits()) {
						const otherFruit = this.fruits.find(f =>
							f != fruit
							&& f.gridPosition.row == fruit.gridPosition.row
							&& f.gridPosition.column == fruit.gridPosition.column
						);

						if (otherFruit && fruit.canSwapWith(otherFruit)) {
							fruit.swapPositionWith(otherFruit);
						} else {
							const isOperationSuccessful = this.moveAwayAllFruitsFrom(fruit, this.plate.grid);

							if (!isOperationSuccessful) {
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

	const priv = {
		container: null,
	};

	priv.vm = new kendo.data.ObservableObject({
		// DATA
		plates: new kendo.data.DataSource({
			data: [
				{
					UUID: "100",
					CODE: "508",
					IMG: "/assets/main/img/508.jpg",
					WIDTH: 1200, // in px
					HEIGHT: 500, // in px
					ORIENTATION: "H", // "V" - VERTICAL, "H" - HORIZONTAL
					CELL_ORIENTATION: "H", // "V" - VERTICAL, "H" - HORIZONTAL. PS: CELL ORIENTATION IS INDIPENDENT FROM PLATE'S ORIENTATION,
					GRID: [
						// LEGEND:
						// "_" - empty free space
						// "0" - prohibited space
						["_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_",],
					],
				},
				{
					UUID: "111",
					CODE: "1X3",
					IMG: "/assets/main/img/1X3.jpg",
					WIDTH: 1200, // in px
					HEIGHT: 500, // in px
					ORIENTATION: "V", // "V" - VERTICAL, "H" - HORIZONTAL
					CELL_ORIENTATION: "H", // "V" - VERTICAL, "H" - HORIZONTAL. PS: CELL ORIENTATION IS INDIPENDENT FROM PLATE'S ORIENTATION,
					GRID: [
						// LEGEND:
						// "_" - empty free space
						// "0" - prohibited space
						["_", "_",],
						["0", "0",],
						["_", "_",],
						["0", "0",],
						["_", "_",],
					],
				},
				{
					UUID: "200",
					CODE: "508V",
					IMG: "/assets/main/img/508VERTICALE.jpg",
					WIDTH: 1200, // in px
					HEIGHT: 500, // in px
					ORIENTATION: "V", // "V" - VERTICAL, "H" - HORIZONTAL
					CELL_ORIENTATION: "V", // "V" - VERTICAL, "H" - HORIZONTAL. PS: CELL ORIENTATION IS INDIPENDENT FROM PLATE'S ORIENTATION,
					GRID: [
						// LEGEND:
						// "_" - empty free space
						// "0" - prohibited space
						["_"],
						["_"],
						["_"],
						["_"],
						["_"],
						["_"],
						["_"],
						["_"],
						["_"],
						["_"],
						["_"],
						["_"],
						["_"],
						["_"],
						["_"],
						["_"],
					],
				},
				{
					UUID: "300",
					CODE: "SPECIAL1",
					IMG: "/assets/main/img/508.jpg",
					WIDTH: 1200, // in px
					HEIGHT: 500, // in px
					ORIENTATION: "H", // "V" - VERTICAL, "H" - HORIZONTAL
					CELL_ORIENTATION: "H", // "V" - VERTICAL, "H" - HORIZONTAL. PS: CELL ORIENTATION IS INDIPENDENT FROM PLATE'S ORIENTATION,
					GRID: [
						// LEGEND:
						// "_" - empty free space
						// "0" - prohibited space
						["_", "_", "_", "_", "0", "_", "_",],
					],
				},
				{
					UUID: "400",
					CODE: "SPECIAL2",
					IMG: "/assets/main/img/508VERTICALE.jpg",
					WIDTH: 1200, // in px
					HEIGHT: 500, // in px
					ORIENTATION: "V", // "V" - VERTICAL, "H" - HORIZONTAL
					CELL_ORIENTATION: "H", // "V" - VERTICAL, "H" - HORIZONTAL. PS: CELL ORIENTATION IS INDIPENDENT FROM PLATE'S ORIENTATION,
					GRID: [
						// LEGEND:
						// "_" - empty free space
						// "0" - prohibited space
						["0", "0", "_", "_",],
						["_", "_", "0", "0",],
						["_", "_", "_", "_",],
					],
				},
				{
					UUID: "500",
					CODE: "SPECIAL3",
					IMG: "/assets/main/img/508.jpg",
					WIDTH: 1200, // in px
					HEIGHT: 500, // in px
					ORIENTATION: "H", // "V" - VERTICAL, "H" - HORIZONTAL
					CELL_ORIENTATION: "H", // "V" - VERTICAL, "H" - HORIZONTAL. PS: CELL ORIENTATION IS INDIPENDENT FROM PLATE'S ORIENTATION,
					GRID: [
						// LEGEND:
						// "_" - empty free space
						// "0" - prohibited space
						["_", "_", "_", "_", "0", "_", "_", "0", "0", "0", "0",],
					],
				},
			],
			schema: {
				model: {
					id: "UUID",
				},
			},
		}),
		selectedPlate: "100",
		fruits: new kendo.data.DataSource({
			data: [],
		}),
		// CONDITIONS
		isPlateDefined: false,
		// ACTIONS
		// GETTERS
		// EVENTS
		onSelectFruit: function (event) {
			event.preventDefault();

			if (this.get("isPlateDefined")) {
				pub.fruitsController.onSelectFruit(event.dataItem);
			} else {
				alert("Spingi prima 'Configura'");
			}
		},
		onClickGenerali: function (event) {

		},
		onClickListaFrutti: function (event) {

		},
		onClickImmagine: function (event) {

		},
		onClickConfigura: function (event) {
			const selectedPlate = this.plates.get(this.get("selectedPlate"));

			FREE_CELL_WIDTH = pageData.GRID_CELL_DIMENSIONS[CELL_TYPE.FREE].WIDTH;
			FREE_CELL_HEIGHT = pageData.GRID_CELL_DIMENSIONS[CELL_TYPE.FREE].HEIGHT;

			if (selectedPlate.CELL_ORIENTATION == ORIENTATION.VERTICAL) {
				const tmp = FREE_CELL_WIDTH;
				FREE_CELL_WIDTH = FREE_CELL_HEIGHT;
				FREE_CELL_HEIGHT = tmp;
			}

			const grid = [];

			for (let iRow = 0; iRow < selectedPlate.GRID.length; iRow++) {
				const row = [];

				for (let iCol = 0; iCol < selectedPlate.GRID[iRow].length; iCol++) {
					const cellType = selectedPlate.GRID[iRow][iCol];

					const cell = new Cell(
						pageData.GRID_CELL_DIMENSIONS[cellType].WIDTH,
						pageData.GRID_CELL_DIMENSIONS[cellType].HEIGHT,
						selectedPlate.CELL_ORIENTATION,
						cellType,
					);

					row.push(cell);
				}

				grid.push(row);
			}

			const plate = new Plate({
				width: selectedPlate.WIDTH,
				height: selectedPlate.HEIGHT,
				orientation: selectedPlate.ORIENTATION,
				cellOrientation: selectedPlate.CELL_ORIENTATION,
				uuid: selectedPlate.UUID,
				code: selectedPlate.CODE,
				img: selectedPlate.IMG,
				grid: grid,
				isSpecial: false,
			});

			pub.fruitsController = new FruitsController({
				plate: plate,
				fruits: [],
			});

			pub.fruitsController.plate.drawGridWithin($(".plate-designer"));

			this.set("isPlateDefined", true);
		},
		// INITS
	});

	pub.init = function (setup) {
		priv.container = setup.container;

		priv.vm.set("fruits", [
			{
				width: pageData.GRID_CELL_DIMENSIONS[CELL_TYPE.FREE].WIDTH * 4,
				height: pageData.GRID_CELL_DIMENSIONS[CELL_TYPE.FREE].HEIGHT * 1,
				columnSpan: 4,
				rowSpan: 1,
				uuid: "A",
				code: "schuko",
				name: "SCHK 2P + 1T",
				img: "/assets/main/img/foto_frutto_schuko.png",
			},
			{
				width: pageData.GRID_CELL_DIMENSIONS[CELL_TYPE.FREE].WIDTH * 2,
				height: pageData.GRID_CELL_DIMENSIONS[CELL_TYPE.FREE].HEIGHT * 1,
				columnSpan: 2,
				rowSpan: 1,
				uuid: "B",
				code: "bipasso",
				name: "BIPAS.",
				img: "/assets/main/img/foto_frutto_bipasso.png",
			},
			{
				width: pageData.GRID_CELL_DIMENSIONS[CELL_TYPE.FREE].WIDTH * 2,
				height: pageData.GRID_CELL_DIMENSIONS[CELL_TYPE.FREE].HEIGHT * 1,
				columnSpan: 2,
				rowSpan: 1,
				uuid: "C",
				code: "cat6",
				name: "CAT 6",
				img: "/assets/main/img/foto_frutto_cat6.png",
			},
			{
				width: pageData.GRID_CELL_DIMENSIONS[CELL_TYPE.FREE].WIDTH * 2,
				height: pageData.GRID_CELL_DIMENSIONS[CELL_TYPE.FREE].HEIGHT * 1,
				columnSpan: 2,
				rowSpan: 1,
				uuid: "I",
				code: "switch",
				name: "INT. Sottile",
				img: "/assets/main/img/foto_frutto_interruttore.png",
			},
		]);

		kendo.bind(priv.container, priv.vm);
	};

	pub.getVM = function () {
		return priv.vm;
	};

	return pub;
}());

AP.plate.map = (function () {
	const { MarkerArea, CustomImageMarker } = markerjs3;

	const pub = {};
	const priv = {
		container: null,
	};

	priv.vm = new kendo.data.ObservableObject({
		// DATA
		// CONDITIONS
		// ACTIONS
		// GETTERS
		// EVENTS
		onClickAddPin: function (event) {
			const markerEditor = priv.markerArea.createMarker(CustomImageMarker);
			markerEditor.marker.defaultSize = { width: 32, height: 32 };
			markerEditor.marker.imageSrc = "../../../../assets/main/img/pin.png";
		},
		onClickZoomIn: function (event) {
			priv.markerArea.zoomLevel += 0.1;
		},
		onClickZoomOut: function (event) {
			if (priv.markerArea.zoomLevel > 0.2) {
				priv.markerArea.zoomLevel -= 0.1;
			}
		},
		onClickZoomReset: function (event) {
			priv.markerArea.zoomLevel = 1;
		},
		onClickExport: function (event) {
			priv.state = JSON.stringify(priv.markerArea.getState());
		},
		onClickImport: function (event) {
			priv.markerArea.restoreState(JSON.parse(priv.state));
		},
		// INITS
	});

	pub.init = function (setup) {
		priv.container = setup.container;
		kendo.bind(setup.container, priv.vm);

		priv.targetImg = document.createElement("img");
		priv.targetImg.src = "../../../../assets/main/img/planimetria.jpg";

		const plateMap = document.querySelector(".plate-map");

		priv.markerArea = new MarkerArea();
		priv.markerArea.targetImage = priv.targetImg;
		plateMap.appendChild(priv.markerArea);
	};

	return pub;
}());