AP.plate = AP.plate || {};

AP.plate.fields = {
	designerRoot: $("#plate-designer-root"),
};

$(document).ready(function () {
	if (AP.plate.fields.designerRoot.length) {
		AP.plate.designer.init();
	}
});

let PLATE_WIDTH;
let PLATE_HEIGHT;
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

const utils = {
	convertAbsolutePosition(position) {
		return {
			row: Math.round(position.top / FREE_CELL_HEIGHT),
			column: Math.round(position.left / FREE_CELL_WIDTH),
		};
	},
};

class FruitPosition {
	constructor(
		row,
		column,
	) {
		this.row = row;
		this.column = column;
	}

	getTop() {
		return this.row * FREE_CELL_HEIGHT;
	}

	getLeft() {
		return this.column * FREE_CELL_WIDTH;
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
	}

	isSquare() {
		return this.width == this.height;
	}
}

class Plate extends Rectangle {
	constructor(parameters) {
		super(parameters.width, parameters.height, parameters.orientation);

		this.uuid = parameters.uuid;
		this.code = parameters.code;
		this.img = parameters.img;
		this.grid = parameters.grid;
		this.isSpecial = parameters.isSpecial;
	}

	/**
	 * Creates HTML nodes and inserts them in the DOM to visualize grid property
	 */
	drawGridWithin($rootNode) {
		const $plateBackground = $("<div/>", {
			"class": "plate-background",
			"css": {
				"width": `${this.width}px`,
				"height": `${this.height}px`,
				"background-image": `url('${this.img}')`,
			},
			"appendTo": $rootNode
		});

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
				cells.push(this.grid[j][i]);
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
			}
		}
	}
}

class Cell extends Rectangle {
	constructor(width, height, orientation, type) {
		super(width, height, orientation);

		this.type = type;
	}
}

class Fruit extends Rectangle {
	constructor(params) {
		super(params.width, params.height, params.orientation);

		this.uuid = params.uuid;
		this.code = params.code;
		this.name = params.name;
		this.img = params.img;

		this._$element = null;
		this._position = null;
		this._originalPosition = null;
		this._lastPosition = null;
	}

	get position() {
		return this._position;
	}

	set position(value) {
		this._position = value;
	}

	get lastPosition() {
		return this._lastPosition;
	}

	set lastPosition(value) {
		this._lastPosition = value;
	}

	get $element() {
		return this._$element;
	}

	set $element(value) {
		this._$element = value;
	}

	initDraggableWidget(controller) {
		const self = this;

		self._$element.draggable({
			// axis: "x", // TODO: rendere parametrico in base alla configurazione: "solo verticale", "solo orizontale", "entrambi"
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

		const x5 = Math.max(this.position.getLeft(), otherFruit.position.getLeft());
		const x6 = Math.min(this.position.getLeft() + this.width, otherFruit.position.getLeft() + otherFruit.width);

		const y5 = Math.max(this.position.getTop(), otherFruit.position.getTop());
		const y6 = Math.min(this.position.getTop() + this.height, otherFruit.position.getTop() + otherFruit.height);

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
		return this.position.row == otherFruit.position.row
			&& this.position.column == otherFruit.position.column
			&& this.position.getTop() + this.height == otherFruit.position.getTop() + otherFruit.height
			&& this.position.getLeft() + this.width == otherFruit.position.getLeft() + otherFruit.width;
	}

	swapPositionWith(otherFruit) {
		this.position = otherFruit.position;
		otherFruit.position = this._originalPosition;
	}

	fitsWithin(containmentGrid) {
		const colSpan = {
			start: this.position.column,
			end: this.position.column + (this.width / FREE_CELL_WIDTH),
		};

		const rowSpan = {
			start: this.position.row,
			end: this.position.row + (this.height / FREE_CELL_HEIGHT),
		};

		return 0 <= colSpan.start && colSpan.end <= containmentGrid[0].length
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
			this.position.getLeft() + (this.width / 2),
			this.position.getTop() + (this.height / 2),
		];

		const otherCenterPoint = [
			otherFruit.position.getLeft() + (otherFruit.width / 2),
			otherFruit.position.getTop() + (otherFruit.height / 2),
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
		return this._originalPosition.column != this.position.column
			|| this._originalPosition.row != this.position.row;
	}

	makePositionSnapshot() {
		this._originalPosition = new FruitPosition(this.position.row, this.position.column);
	}

	restorePositionToLastSnapshot() {
		this.position = this._originalPosition;
	}

	startDragging() {
		this.$element.addClass("is-dragging");
	}

	stopDragging() {
		this.$element.removeClass("is-dragging");
	}

	/**
	 * Renders Fruit based on current position
	 */
	render() {
		this.$element.css({
			left: this.position.getLeft(),
			top: this.position.getTop(),
		});
	}
}

class FruitsController {
	constructor(params) {
		this.plate = params.plate;
		this.fruits = params.fruits;
	}

	/**
	 *	Creates HTML nodes and inserts them in the DOM to visualize fruits on the grid
	 */
	drawFruitsWithin($rootNode) {
		const $fruits = $("<div/>", {
			"id": "fruits",
			"appendTo": $rootNode
		});

		for (let i = 0; i < this.fruits.length; i++) {
			const fruit = this.fruits[i];

			const $fruit = $("<div/>", {
				"id": fruit.uuid,
				"class": "draggable-fruit",
				"css": {
					"top": `${fruit.position.getTop()}px`,
					"left": `${fruit.position.getLeft()}px`,
					"width": `${fruit.width}px`,
					"height": `${fruit.height}px`,
				},
				"appendTo": $fruits,
			});

			const imgCSS = {
				"width": `${fruit.width}px`,
				"height": `${fruit.height}px`,
			};

			if (fruit.orientation == ORIENTATION.VERTICAL) {
				const tmp = imgCSS.width;
				imgCSS.width = imgCSS.height;
				imgCSS.height = tmp;

				if (fruit.isSquare()) {
					imgCSS.transform = "rotate(90deg)";
				} else {
					imgCSS.transform = "rotate(90deg) translate(-50%, 0%)";
				}
			}

			const $img = $("<img/>", {
				"src": fruit.img,
				"class": "fruit-img",
				"css": imgCSS,
				"appendTo": $fruit,
			});

			fruit.$element = $fruit;
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

	isFruitInProhibitedPosition(fruit) {
		const rowRange = { start: fruit.position.row, end: fruit.position.row + (fruit.height / FREE_CELL_HEIGHT) };
		const colRange = { start: fruit.position.column, end: fruit.position.column + (fruit.width / FREE_CELL_WIDTH) };

		const subGrid = AP.util.slice2DArray({
			array: this.plate.grid,
			rowRange: rowRange,
			colRange: colRange,
		});

		const result = subGrid.some(row => row.some(cell => cell.type == CELL_TYPE.PROHIBITED));

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
		const convertedPosition = utils.convertAbsolutePosition({
			left: vector[0],
			top: vector[1],
		});

		fruit.position = new FruitPosition(
			fruit.position.row - convertedPosition.row,
			fruit.position.column - convertedPosition.column,
		);

		return !this.isFruitInProhibitedPosition(fruit)
			&& fruit.fitsWithin(this.plate.grid);
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
		fruit.lastPosition = fruit.position;

		const convertedPosition = utils.convertAbsolutePosition(ui.position);
		fruit.position = new FruitPosition(convertedPosition.row, convertedPosition.column);

		if (this.isFruitInProhibitedPosition(fruit)) {
			fruit.position = fruit.lastPosition;

			ui.position.left = fruit.position.getLeft();
			ui.position.top = fruit.position.getTop();
		}
	}

	/**
	 * Triggered when dragging stops
	 * @param {Fruit} fruit
	 * @param {Event} event
	 * @param {object} ui
	 */
	onStopDragging(fruit, event, ui) {
		const convertedPosition = utils.convertAbsolutePosition(ui.position);
		fruit.position = new FruitPosition(convertedPosition.row, convertedPosition.column);

		if (fruit.hasChangedPosition()) {
			if (this.hasOverlappedFruits()) {
				const otherFruit = this.fruits.find(f =>
					f != fruit
					&& f.position.row == fruit.position.row
					&& f.position.column == fruit.position.column
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

		fruit.stopDragging();

		this.renderFruits();
	}
}

AP.plate.designer = (function () {
	var pub = {};

	pub.init = function () {
		/*
		Sappiamo:
			- l'orientamento della placca
			- width e height dell'intera placca
			- griglia dell'intera placca
			- width e height di un sottomodulo
		*/

		PLATE_WIDTH = pageData.PLATE.WIDTH;
		PLATE_HEIGHT = pageData.PLATE.HEIGHT;
		FREE_CELL_WIDTH = pageData.GRID_CELL_DIMENSIONS[CELL_TYPE.FREE].WIDTH;
		FREE_CELL_HEIGHT = pageData.GRID_CELL_DIMENSIONS[CELL_TYPE.FREE].HEIGHT;

		if (pageData.GRID_CELL_DIMENSIONS[CELL_TYPE.FREE].ORIENTATION == ORIENTATION.VERTICAL) {
			const tmp = FREE_CELL_WIDTH;
			FREE_CELL_WIDTH = FREE_CELL_HEIGHT;
			FREE_CELL_HEIGHT = tmp;
		}

		const grid = [];
		for (let iRow = 0; iRow < pageData.PLATE.GRID.length; iRow++) {
			const row = [];

			for (let iCol = 0; iCol < pageData.PLATE.GRID[iRow].length; iCol++) {
				const cellType = pageData.PLATE.GRID[iRow][iCol];

				row.push(new Cell(
					pageData.GRID_CELL_DIMENSIONS[cellType].WIDTH,
					pageData.GRID_CELL_DIMENSIONS[cellType].HEIGHT,
					pageData.GRID_CELL_DIMENSIONS[cellType].ORIENTATION,
					cellType,
				));
			}

			grid.push(row);
		}

		const plate = new Plate({
			width: pageData.PLATE.WIDTH,
			height: pageData.PLATE.HEIGHT,
			orientation: pageData.PLATE.ORIENTATION,
			uuid: pageData.PLATE.UUID,
			code: pageData.PLATE.CODE,
			img: pageData.PLATE.IMG,
			grid: grid,
			isSpecial: false,
		});

		plate.drawGridWithin($(".plate-designer"));

		const fruits = [];

		for (const fruit of Object.values(pageData.FRUITS)) {
			const fruitObj = new Fruit({
				width: fruit.width,
				height: fruit.height,
				orientation: fruit.orientation,
				uuid: fruit.uuid,
				code: fruit.code,
				name: fruit.name,
				img: fruit.img,
			});

			fruitObj.position = new FruitPosition(
				fruit.row,
				fruit.column,
			);

			fruits.push(fruitObj);
		}

		const fruitController = new FruitsController({
			plate: plate,
			fruits: fruits,
		});

		fruitController.drawFruitsWithin($("#plate-layers"));
		fruitController.makeFruitsDraggable();
	};

	return pub;
}());
