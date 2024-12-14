AP.plate = AP.plate || {};

AP.plate.fields = {
	designerRoot: $("#plate-designer-root"),
};

$(document).ready(function () {
	if (AP.plate.fields.designerRoot.length) {
		AP.plate.designer.init();
	}
});

AP.plate.designer = (function () {
	var pub = {};

	pub.init = function () {
		const CELL_TYPES = {
			EMPTY: "_",
			PROHIBITED: "0",
		};
		const CELL_SIZE_IN_X = pageData.GRID_CELL_DIMENSIONS.WIDTH;
		const CELL_SIZE_IN_Y = pageData.GRID_CELL_DIMENSIONS.HEIGHT;
		const MOVING_DIRECTIONS = {
			LEFT: "←",
			RIGHT: "→",
			UP: "↑",
			DOWN: "↓",
			NONE: "",
		};

		const plateGrid = pageData.PLATE_GRID;

		const MIN_DISTANCE_BEFORE_DRAGGING = 0;

		function parseBoundingBox(uiElement) {
			const elementBounds = uiElement.helper[0].getBoundingClientRect();

			const result = {
				id: uiElement.helper.attr("id"),
				x1: uiElement.position.left / CELL_SIZE_IN_X,
				x2: null,
				deltaX: 0,
				directionX: MOVING_DIRECTIONS.NONE,
				y1: uiElement.position.top / CELL_SIZE_IN_Y,
				y2: null,
				deltaY: 0,
				directionY: MOVING_DIRECTIONS.NONE,
				width: elementBounds.width / CELL_SIZE_IN_X,
				height: elementBounds.height / CELL_SIZE_IN_Y,
				originalPosition: {
					x1: uiElement.originalPosition.left / CELL_SIZE_IN_X,
					x2: null,
					y1: uiElement.originalPosition.top / CELL_SIZE_IN_Y,
					y2: null,
				},
			};

			result.x2 = result.x1 + result.width - 1;
			result.y2 = result.y1 + result.height - 1;

			result.originalPosition.x2 = result.originalPosition.x1 + result.width - 1;
			result.originalPosition.y2 = result.originalPosition.y1 + result.height - 1;

			result.deltaX = result.x2 - result.originalPosition.x2;
			const deltaXSign = Math.sign(result.deltaX);
			if (deltaXSign == 1) {
				result.directionX = MOVING_DIRECTIONS.RIGHT;
			} else if (deltaXSign == -1) {
				result.directionX = MOVING_DIRECTIONS.LEFT;
			}

			result.deltaY = result.y2 - result.originalPosition.y2;
			const deltaYSign = Math.sign(result.deltaY);
			if (deltaYSign == 1) {
				result.directionY = MOVING_DIRECTIONS.DOWN;
			} else if (deltaYSign == -1) {
				result.directionY = MOVING_DIRECTIONS.UP;
			}

			return result;
		}

		function isProhibitedPosition(plateItemPosition, grid) {
			let result = false;

			// Broad phase
			const axisRanges = extract2dAxisRanges(plateItemPosition);

			const gridSection = AP.util.slice2DArray({
				array: grid,
				rowRange: axisRanges.y,
				colRange: axisRanges.x,
				isInclusiveEnd: true,
			});

			// Narrow phase
			result = gridSection.some(row => row.some(cell => cell == CELL_TYPES.PROHIBITED));

			return result;
		}

		function extractPlateItemsFrom(grid, cellPredicate = () => true) {
			const result = {};

			for (const row of grid) {
				for (const cell of row) {
					if (cellPredicate(cell)) {
						if (!result.hasOwnProperty(cell)) {
							result[cell] = pageData.PLATE_ELEMENTS[cell];
						}
					}
				}
			}

			return result;
		}

		function isColliding(plateItemPosition, grid) {
			let result = false;

			// Broad phase
			const axisRanges = extract2dAxisRanges(plateItemPosition);
			const subGrid = AP.util.slice2DArray({
				array: grid,
				rowRange: axisRanges.y,
				colRange: axisRanges.x,
				isInclusiveEnd: true,
			});

			const possibleBoxes = extractPlateItemsFrom(
				subGrid,
				cell => cell != plateItemPosition.id && cell != CELL_TYPES.EMPTY && cell != CELL_TYPES.PROHIBITED
			);

			// Narrow phase
			for (const [key, candidateBox] of Object.entries(possibleBoxes)) {
				if (
					candidateBox.x1 <= plateItemPosition.x2 && candidateBox.x2 >= plateItemPosition.x1
					&&
					candidateBox.y1 <= plateItemPosition.y2 && candidateBox.y2 >= plateItemPosition.y1
				) {
					result = true;

					break;
				}
			}

			return result;
		}

		function isPossibleToMoveByDeltas(params) {
			let result = false;

			const gridMargins = {
				left: 0,
				right: params.grid[0].length - 1,
				up: 0,
				down: params.grid.length - 1,
			};

			const newCoordinateX = params.plateItem.x1 + params.deltaX;
			if (gridMargins.left <= newCoordinateX && newCoordinateX <= gridMargins.right) {
				result = true;
			}

			// TODO:
			// const newCoordinateY = params.plateItem.y1 + params.deltaY;
			// if (gridMargins.up <= newCoordinateY && newCoordinateY <= gridMargins.down) {
			// 	result = true;
			// }

			return result;
		}

		function canPushCollidedItem(plateItemPosition, grid) {
			let result = false;

			// Broad phase
			const axisRanges = extract2dAxisRanges(plateItemPosition);
			const subGrid = AP.util.slice2DArray({
				array: grid,
				rowRange: axisRanges.y,
				colRange: axisRanges.x,
				isInclusiveEnd: true,
			});

			// Narrow phase
			const possibleBoxes = extractPlateItemsFrom(
				subGrid,
				cell => cell != plateItemPosition.id && cell != CELL_TYPES.EMPTY && cell != CELL_TYPES.PROHIBITED
			);

			const collidedPlateItemKeys = Object.keys(possibleBoxes);
			if (collidedPlateItemKeys.length == 1) {
				result = isPossibleToMoveByDeltas({
					plateItem: possibleBoxes[collidedPlateItemKeys[0]],
					deltaX: plateItemPosition.deltaX,
					deltaY: plateItemPosition.deltaY,
					grid: grid
				});
			}

			return result;
		}

		function changePositionsPushingCollidingItem(plateItemPosition, grid) {
			// Broad phase
			const axisRanges = extract2dAxisRanges(plateItemPosition);
			const subGrid = AP.util.slice2DArray({
				array: grid,
				rowRange: axisRanges.y,
				colRange: axisRanges.x,
				isInclusiveEnd: true,
			});

			// Narrow phase
			const possibleBoxes = extractPlateItemsFrom(
				subGrid,
				cell => cell != plateItemPosition.id && cell != CELL_TYPES.EMPTY && cell != CELL_TYPES.PROHIBITED
			);

			const collidedPlateItemKeys = Object.keys(possibleBoxes);
			if (collidedPlateItemKeys.length == 1) {
				const collidingItemToPushKey = collidedPlateItemKeys[0];
				const collidingItemToPush = possibleBoxes[collidingItemToPushKey];

				AP.util.splice2DArray({
					array: grid,
					rowRange: { start: collidingItemToPush.y1, end: collidingItemToPush.y2 },
					colRange: { start: collidingItemToPush.x1, end: collidingItemToPush.x2 },
					replaceItem: CELL_TYPES.EMPTY,
					isInclusiveEnd: true,
				});

				console.table(grid);

				AP.util.splice2DArray({
					array: grid,
					rowRange: { start: collidingItemToPush.y1 + plateItemPosition.deltaY, end: collidingItemToPush.y2 + plateItemPosition.deltaY },
					colRange: { start: collidingItemToPush.x1 + plateItemPosition.deltaX, end: collidingItemToPush.x2 + plateItemPosition.deltaX },
					replaceItem: collidingItemToPushKey,
					isInclusiveEnd: true,
				});

				updatePlateItemNewPosition(plateItemPosition, grid);
			}

			updatePlateItemsCoordinates(grid);
		}

		// TODO:
		function canSwapWithCollidedItem(plateItemPosition, grid) {
			return false;
			let result = false;

			// Broad phase
			const axisRanges = extract2dAxisRanges(plateItemPosition);
			const subGrid = AP.util.slice2DArray({
				array: grid,
				rowRange: axisRanges.y,
				colRange: axisRanges.x,
				isInclusiveEnd: true,
			});

			// Narrow phase
			const possibleBoxes = extractPlateItemsFrom(
				subGrid,
				cell => cell != plateItemPosition.id && cell != CELL_TYPES.EMPTY && cell != CELL_TYPES.PROHIBITED
			);

			result = Object.keys(possibleBoxes).length == 1;

			return result;
		}

		function swapPositionsWithCollidingItem(itemBoundingBox, grid) {
			const newPositionAxisRanges = extract2dAxisRanges(itemBoundingBox);

			console.table(grid);

			const subGridNewPosition = AP.util.slice2DArray({
				array: grid,
				rowRange: newPositionAxisRanges.y,
				colRange: newPositionAxisRanges.x,
				isInclusiveEnd: true,
			});

			const collidedPlateItemKeys = new Set(subGridNewPosition.flat());

			if (collidedPlateItemKeys.size == 2) {
				const originalPositionAxisRanges = extract2dAxisRanges(itemBoundingBox.originalPosition);
				const collidedPlateItems = extractPlateItemsFrom(grid, cell => collidedPlateItemKeys.has(cell));

				const subGridOriginalPosition = AP.util.splice2DArray({
					array: grid,
					rowRange: originalPositionAxisRanges.y,
					colRange: originalPositionAxisRanges.x,
					replaceItem: CELL_TYPES.EMPTY,
					isInclusiveEnd: true,
				});

				console.table(grid);

				// const replaceItemNewPosition = replacingItemKey.values().next().value;

				const subGridNewPosition = AP.util.splice2DArray({
					array: grid,
					rowRange: newPositionAxisRanges.y,
					colRange: newPositionAxisRanges.x,
					replaceItem: CELL_TYPES.EMPTY,
					isInclusiveEnd: true,
				});

				console.table(grid);
			}

			console.table(grid);

			updatePlateItemsCoordinates(grid);
		}

		function extract2dAxisRanges(position) {
			return {
				x: { start: position.x1, end: position.x2 },
				y: { start: position.y1, end: position.y2 },
			};
		}

		function updatePlateItemNewPosition(itemBoundingBox, grid) {
			const originalPositionAxisRanges = extract2dAxisRanges(itemBoundingBox.originalPosition);
			const newPositionAxisRanges = extract2dAxisRanges(itemBoundingBox);

			const subGridOriginalPosition = AP.util.splice2DArray({
				array: grid,
				rowRange: originalPositionAxisRanges.y,
				colRange: originalPositionAxisRanges.x,
				replaceItem: CELL_TYPES.EMPTY,
				isInclusiveEnd: true,
			});

			const subGridNewPosition = AP.util.splice2DArray({
				array: grid,
				rowRange: newPositionAxisRanges.y,
				colRange: newPositionAxisRanges.x,
				replaceItem: CELL_TYPES.EMPTY,
				isInclusiveEnd: true,
			});

			const replacingItemKey = new Set(subGridOriginalPosition.flat());
			let replacedItemKeys = new Set(subGridNewPosition.flat());
			if (replacedItemKeys.size == 2 && replacedItemKeys.has(CELL_TYPES.EMPTY)) {
				replacedItemKeys = new Set(subGridNewPosition.flat().filter(i => i != CELL_TYPES.EMPTY));
			}

			if (replacingItemKey.size == 1 && replacedItemKeys.size == 1) {
				const replaceItemOriginalPosition = replacedItemKeys.values().next().value;

				const subGridOriginalPosition = AP.util.splice2DArray({
					array: grid,
					rowRange: originalPositionAxisRanges.y,
					colRange: originalPositionAxisRanges.x,
					replaceItem: replaceItemOriginalPosition,
					isInclusiveEnd: true,
				});

				const replaceItemNewPosition = replacingItemKey.values().next().value;

				const subGridNewPosition = AP.util.splice2DArray({
					array: grid,
					rowRange: newPositionAxisRanges.y,
					colRange: newPositionAxisRanges.x,
					replaceItem: replaceItemNewPosition,
					isInclusiveEnd: true,
				});
			}

			console.table(grid);

			updatePlateItemsCoordinates(grid);
		}

		function updatePlateItemsCoordinates(grid) {
			const plateItems = extractPlateItemsFrom(
				grid,
				cell => cell != CELL_TYPES.EMPTY && cell != CELL_TYPES.PROHIBITED
			);

			const plateItemsMap = {};
			for (let y = 0; y < grid.length; y++) {
				const row = grid[y];

				for (let x = 0; x < grid.length; x++) {
					const plateItemKey = row[x];

					if (plateItems.hasOwnProperty(plateItemKey)) {
						if (!plateItemsMap.hasOwnProperty(plateItemKey)) {
							plateItemsMap[plateItemKey] = {
								x: new Set(),
								y: new Set(),
							};
						}

						plateItemsMap[plateItemKey].x.add(x);
						plateItemsMap[plateItemKey].y.add(y);
					}
				}
			}

			Object.entries(plateItems).forEach(([plateItemKey, value]) => {
				const updatedPlateItem = plateItemsMap[plateItemKey];
				const coordsX = Array.from(updatedPlateItem.x);
				const coordsY = Array.from(updatedPlateItem.y);

				value.x1 = Math.min(...coordsX);
				value.x2 = Math.max(...coordsX);

				value.y1 = Math.min(...coordsY);
				value.y2 = Math.max(...coordsY);
			});
		}

		function isChangedPlateItemFinalPosition(plateItem) {
			return plateItem.originalPosition.top != plateItem.position.top
				|| plateItem.originalPosition.left != plateItem.position.left;
		}

		function renderGrid(plateGrid) {
			const allBoxes = extractPlateItemsFrom(
				plateGrid,
				cell => cell != CELL_TYPES.EMPTY && cell != CELL_TYPES.PROHIBITED
			);

			for (const [key, box] of Object.entries(allBoxes)) {
				const $box = $(`#${key}`);

				$box.css("left", box.x1 * CELL_SIZE_IN_X);
				$box.css("top", box.y1 * CELL_SIZE_IN_Y);
			}
		}

		$(".draggable-plate-item").draggable({
			// axis: "x", // TODO: rendere parametrico in base alla configurazione: "solo verticale", "solo orizontale", "entrambi"
			containment: "#plate-grid",
			distance: MIN_DISTANCE_BEFORE_DRAGGING,
			grid: [CELL_SIZE_IN_X, CELL_SIZE_IN_Y],
			// revert: true,
			revertDuration: 250,
			start: function (event, ui) {
				const $draggablePlateItem = ui.helper;

				$draggablePlateItem.addClass("is-dragging");
			},
			drag: function (event, ui) {
				const $draggablePlateItem = ui.helper;

				const newBoundingBox = parseBoundingBox(ui);

				if (isProhibitedPosition(newBoundingBox, plateGrid)) {
					ui.position.left = ui.originalPosition.left;
					ui.position.top = ui.originalPosition.top;
				} else {
					if (isColliding(newBoundingBox, plateGrid)) {
						$draggablePlateItem.addClass("is-colliding");

						if (!canSwapWithCollidedItem(newBoundingBox, plateGrid)) {
							$draggablePlateItem.addClass("is-not-swappable");
						} else {
							$draggablePlateItem.removeClass("is-not-swappable");
						}
					} else {
						$draggablePlateItem.removeClass("is-colliding");
					}
				}

			},
			stop: function (event, ui) {
				const $draggablePlateItem = ui.helper;

				$draggablePlateItem.removeClass("is-dragging");
				$draggablePlateItem.removeClass("is-not-swappable");

				if (isChangedPlateItemFinalPosition(ui)) {
					const newBoundingBox = parseBoundingBox(ui);

					if (isColliding(newBoundingBox, plateGrid)) {
						if (canPushCollidedItem(newBoundingBox, plateGrid)) {
							changePositionsPushingCollidingItem(newBoundingBox, plateGrid);
						} else if (canSwapWithCollidedItem(newBoundingBox, plateGrid)) {
							swapPositionsWithCollidingItem(newBoundingBox, plateGrid);
						}
					} else {
						updatePlateItemNewPosition(newBoundingBox, plateGrid);
					}

					renderGrid(plateGrid);
				}
			},
		});
	};

	return pub;
}());