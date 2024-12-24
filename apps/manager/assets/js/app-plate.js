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

		const MIN_DISTANCE_BEFORE_DRAGGING = 1;

		function parseBoundingBox(uiElement) {
			const elementBounds = uiElement.helper[0].getBoundingClientRect();

			const result = {
				id: uiElement.helper.attr("id"),
				x1: Math.round(uiElement.position.left / CELL_SIZE_IN_X),
				x2: null,
				deltaX: 0,
				directionX: MOVING_DIRECTIONS.NONE,
				y1: Math.round(uiElement.position.top / CELL_SIZE_IN_Y),
				y2: null,
				deltaY: 0,
				directionY: MOVING_DIRECTIONS.NONE,
				width: elementBounds.width / CELL_SIZE_IN_X,
				height: elementBounds.height / CELL_SIZE_IN_Y,
				originalPosition: {
					x1: Math.round(uiElement.originalPosition.left / CELL_SIZE_IN_X),
					x2: null,
					y1: Math.round(uiElement.originalPosition.top / CELL_SIZE_IN_Y),
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
			const axisRanges = extract2DAxisRanges(plateItemPosition);

			// console.log(axisRanges.x, axisRanges.y);

			const gridSection = AP.util.slice2DArray({
				array: grid,
				rowRange: axisRanges.y,
				colRange: axisRanges.x,
				isInclusiveEnd: true,
			});

			// console.table(gridSection);

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

		function getOverlappingMetadata(plateItemPosition, grid) {
			const result = {
				overlappedPlateItems: [],
				isOverlapping: false,
			};

			// Broad phase
			const axisRanges = extract2DAxisRanges(plateItemPosition);
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

			result.isOverlapping = Object.entries(possibleBoxes).length > 0;

			// Narrow phase
			for (const [key, candidateBox] of Object.entries(possibleBoxes)) {
				const x5 = Math.max(plateItemPosition.x1, candidateBox.x1);
				const x6 = Math.min(plateItemPosition.x2, candidateBox.x2);
				const width = x6 - x5 + 1;

				const y5 = Math.max(plateItemPosition.y1, candidateBox.y1);
				const y6 = Math.min(plateItemPosition.y2, candidateBox.y2);
				const height = y6 - y5 + 1;

				if (x5 > x6) {
					result.isOverlapping = false;

					break;
				}

				if (y5 > y6) {
					result.isOverlapping = false;

					break;
				}

				result.overlappedPlateItems.push({
					item: candidateBox,
					overlappedWidth: width,
					overlappedHeight: height,
				});
			}

			return result;
		}

		function getCenteredIndexes(xRange) {
			const result = {
				x1: null,
				x2: null,
			};

			const arrLen = xRange.end - xRange.start;

			if (arrLen >= 2 && arrLen % 2 == 0) {
				result.x1 = xRange.start + (arrLen / 2) - 1;
				result.x2 = xRange.end - (arrLen / 2);
			}

			return result;
		}

		function canPushOverlappedItems(overlappingMetadata, plateItem, grid) {
			let result = {
				canPush: false,
				pushedPlateItem: null,
				x1: 0,
				x2: 0,
				y1: 0,
				y2: 0,
			};

			if (overlappingMetadata.overlappedPlateItems.length	> 1) {
				return result;
			}

			const firstPlateItemMetadata = overlappingMetadata.overlappedPlateItems[0];
			const pushedPlateItemWidth = firstPlateItemMetadata.item.x2 - firstPlateItemMetadata.item.x1 + 1;

			if (plateItem.width >= firstPlateItemMetadata.overlappedWidth && plateItem.width != pushedPlateItemWidth) {
				const centerIndexesPushedItem = getCenteredIndexes({
					start: firstPlateItemMetadata.item.x1,
					end: firstPlateItemMetadata.item.x2 + 1,
				});

				const centerIndexesPlateItem = getCenteredIndexes({
					start: plateItem.x1,
					end: plateItem.x2 + 1,
				});

				if (
					centerIndexesPushedItem.x1 == centerIndexesPlateItem.x1
					&& centerIndexesPushedItem.x2 == centerIndexesPlateItem.x2
				) {
					return result;
				}
			}

			result.pushedPlateItem = firstPlateItemMetadata.item;

			const gridMargins = {
				left: 0,
				right: grid[0].length - 1,
				up: 0,
				down: grid.length - 1,
			};

			const isOverlappingOnLeftSide = plateItem.x1 <= result.pushedPlateItem.x1;

			const deltaX = isOverlappingOnLeftSide ? firstPlateItemMetadata.overlappedWidth : -firstPlateItemMetadata.overlappedWidth;

			let newCoordinateX1 = result.pushedPlateItem.x1 + deltaX;
			let newCoordinateX2 = result.pushedPlateItem.x2 + deltaX;

			if (
				gridMargins.left <= newCoordinateX1 && newCoordinateX1 <= gridMargins.right
				&& gridMargins.left <= newCoordinateX2 && newCoordinateX2 <= gridMargins.right
			) {
				const axisRangesPossibleLeft = extract2DAxisRanges(result.pushedPlateItem);
				axisRangesPossibleLeft.x.start += deltaX;
				axisRangesPossibleLeft.x.end += deltaX;

				const subGrid = AP.util.slice2DArray({
					array: grid,
					rowRange: axisRangesPossibleLeft.y,
					colRange: axisRangesPossibleLeft.x,
					isInclusiveEnd: true,
				});

				// Narrow phase
				const possibleBoxes = extractPlateItemsFrom(
					subGrid,
					cell => cell != result.pushedPlateItem.id && cell != CELL_TYPES.EMPTY && cell != CELL_TYPES.PROHIBITED
				);

				if (Object.keys(possibleBoxes).length == 0) {
					result.canPush = true;

					result.x1 = axisRangesPossibleLeft.x.start;
					result.x2 = axisRangesPossibleLeft.x.end;
				}
			}

			// TODO:
			// const newCoordinateY = params.plateItem.y1 + params.deltaY;
			// if (gridMargins.up <= newCoordinateY && newCoordinateY <= gridMargins.down) {
			// 	result = true;
			// }

			return result;
		}

		function changePositionsPushingOverlappedItem(pushingMetadata, plateItemPosition, grid) {
			const oldAxisRangesPushedItem = extract2DAxisRanges(pushingMetadata.pushedPlateItem);

			AP.util.splice2DArray({
				array: grid,
				rowRange: oldAxisRangesPushedItem.y,
				colRange: oldAxisRangesPushedItem.x,
				replaceItem: CELL_TYPES.EMPTY,
				isInclusiveEnd: true,
			});

			console.table(grid);

			const newAxisRangesPushedItem = extract2DAxisRanges(pushingMetadata);

			AP.util.splice2DArray({
				array: grid,
				rowRange: newAxisRangesPushedItem.y,
				colRange: newAxisRangesPushedItem.x,
				replaceItem: pushingMetadata.pushedPlateItem.id,
				isInclusiveEnd: true,
			});

			console.table(grid);

			updatePlateItemNewPosition(plateItemPosition, grid);

			updatePlateItemsCoordinates(grid);
		}

		function canSwapWithOverlappedItems(overlappingMetadata, plateItem) {
			if (overlappingMetadata.overlappedPlateItems.length > 1) {
				return false;
			}

			const firstMetadata = overlappingMetadata.overlappedPlateItems[0];
			const overlappedItem = firstMetadata.item;
			const overlappedItemWidth = overlappedItem.x2 - overlappedItem.x1 + 1;
			const overlappedItemHeight = overlappedItem.y2 - overlappedItem.y1 + 1;

			return overlappedItemWidth == plateItem.width
				&& overlappedItemHeight == plateItem.height
				&& firstMetadata.overlappedWidth == plateItem.width
				&& firstMetadata.overlappedHeight == plateItem.height;
		}

		function swapPositionsWithOverlappedItem(overlappingMetadata, plateItem, grid) {
			console.table(grid);

			const originalPositionAxisRanges = extract2DAxisRanges(plateItem.originalPosition);
			AP.util.splice2DArray({
				array: grid,
				rowRange: originalPositionAxisRanges.y,
				colRange: originalPositionAxisRanges.x,
				replaceItem: overlappingMetadata.overlappedPlateItems[0].item.id,
				isInclusiveEnd: true,
			});

			console.table(grid);

			const newPositionAxisRanges = extract2DAxisRanges(plateItem);
			AP.util.splice2DArray({
				array: grid,
				rowRange: newPositionAxisRanges.y,
				colRange: newPositionAxisRanges.x,
				replaceItem: plateItem.id,
				isInclusiveEnd: true,
			});

			console.table(grid);

			updatePlateItemsCoordinates(grid);
		}

		function extract2DAxisRanges(position) {
			return {
				x: { start: position.x1, end: position.x2 },
				y: { start: position.y1, end: position.y2 },
			};
		}

		function updatePlateItemNewPosition(itemBoundingBox, grid) {
			const newPositionAxisRanges = extract2DAxisRanges(itemBoundingBox);

			AP.util.splice2DArray({
				array: grid,
				rowRange: newPositionAxisRanges.y,
				colRange: newPositionAxisRanges.x,
				replaceItem: itemBoundingBox.id,
				isInclusiveEnd: true,
			});

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

				for (let x = 0; x < row.length; x++) {
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
			return plateItem.originalPosition.y1 != plateItem.y1
				|| plateItem.originalPosition.x1 != plateItem.x1;
		}

		function restoreInitialPosition(plateItemPosition, grid) {
			const axisRanges = extract2DAxisRanges(plateItemPosition.originalPosition);

			AP.util.splice2DArray({
				array: grid,
				rowRange: axisRanges.y,
				colRange: axisRanges.x,
				replaceItem: plateItemPosition.id,
				isInclusiveEnd: true,
			});
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
			containment: "#plate-items",
			distance: MIN_DISTANCE_BEFORE_DRAGGING,
			grid: [CELL_SIZE_IN_X],
			revertDuration: 250,
			start: function (event, ui) {
				const $draggablePlateItem = ui.helper;

				$draggablePlateItem.addClass("is-dragging");

				const originalBoundingBox = parseBoundingBox(ui);
				const axisRanges = extract2DAxisRanges(originalBoundingBox.originalPosition);

				AP.util.splice2DArray({
					array: plateGrid,
					rowRange: axisRanges.y,
					colRange: axisRanges.x,
					replaceItem: CELL_TYPES.EMPTY,
					isInclusiveEnd: true,
				});
			},
			drag: function (event, ui) {
				// const $draggablePlateItem = ui.helper;

				// const newBoundingBox = parseBoundingBox(ui);

				// console.log(newBoundingBox.x1, newBoundingBox.x2, newBoundingBox.deltaX, newBoundingBox.directionX);
				// console.log(ui.position);

				// if (isProhibitedPosition(newBoundingBox, plateGrid)) {
				// ui.position.left = ui.originalPosition.left;
				// ui.position.top = ui.originalPosition.top;
				// } else {
				// 	if (isColliding(newBoundingBox, plateGrid)) {
				// 		$draggablePlateItem.addClass("is-colliding");

				// 		if (!canSwapWithCollidingItem(newBoundingBox, plateGrid)) {
				// 			$draggablePlateItem.addClass("is-not-swappable");
				// 		} else {
				// 			$draggablePlateItem.removeClass("is-not-swappable");
				// 		}
				// 	} else {
				// 		$draggablePlateItem.removeClass("is-colliding");
				// 	}
				// }

			},
			stop: function (event, ui) {
				const $draggablePlateItem = ui.helper;

				$draggablePlateItem.removeClass("is-dragging");
				$draggablePlateItem.removeClass("is-not-swappable");

				const newBoundingBox = parseBoundingBox(ui);

        if (isChangedPlateItemFinalPosition(newBoundingBox)) {
					const overlappingMetadata = getOverlappingMetadata(newBoundingBox, plateGrid);

					if (overlappingMetadata.isOverlapping) {
						if (canSwapWithOverlappedItems(overlappingMetadata, newBoundingBox)) {
							swapPositionsWithOverlappedItem(overlappingMetadata, newBoundingBox, plateGrid);
						} else {
							const pushingMetadata = canPushOverlappedItems(overlappingMetadata, newBoundingBox, plateGrid);

							if (pushingMetadata.canPush) {
								changePositionsPushingOverlappedItem(pushingMetadata, newBoundingBox, plateGrid);
							} else {
								restoreInitialPosition(newBoundingBox, plateGrid);
							}
						}
					} else {
						updatePlateItemNewPosition(newBoundingBox, plateGrid);
					}
				} else {
					restoreInitialPosition(newBoundingBox, plateGrid);
				}

				renderGrid(plateGrid);
			},
		});
	};

	return pub;
}());