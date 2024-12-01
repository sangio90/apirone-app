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

		const plateGrid = pageData.PLATE_GRID;

		const MIN_DISTANCE_BEFORE_DRAGGING = 0;

		function parseBoundingBox(uiElement) {
			const elementBounds = uiElement.helper[0].getBoundingClientRect();

			const result = {
				id: uiElement.helper.attr("id"),
				x1: uiElement.position.left / CELL_SIZE_IN_X,
				x2: null,
				y1: uiElement.position.top / CELL_SIZE_IN_Y,
				y2: null,
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

		function canSwapWithCollidedItem(plateItemPosition, grid) {
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

		// TODO:
		function swapPositionsWithCollidingItem(plateItemPosition, grid) {

		}

		function extract2dAxisRanges(position) {
			return {
				x: { start: position.x1, end: position.x2 },
				y: { start: position.y1, end: position.y2 },
			};
		}

		// TODO: manca la gestione di una mezza mossa (la grid non contiene la reale situazione quando muovo in verticale di un mezzo passo)
		function updatePlateItemNewPosition(ui, grid) {
			const itemBoundingBox = parseBoundingBox(ui);

			const originalPositionAxisRanges = extract2dAxisRanges(itemBoundingBox.originalPosition);

			const subGridOriginalPosition = AP.util.slice2DArray({
				array: grid,
				rowRange: originalPositionAxisRanges.y,
				colRange: originalPositionAxisRanges.x,
				isInclusiveEnd: true,
			});

			const plateItem = extractPlateItemsFrom(
				subGridOriginalPosition,
				cell => cell == itemBoundingBox.id
			);

			if (plateItem.hasOwnProperty(itemBoundingBox.id)) {
				plateItem[itemBoundingBox.id].x1 = itemBoundingBox.x1;
				plateItem[itemBoundingBox.id].x2 = itemBoundingBox.x2;
				plateItem[itemBoundingBox.id].y1 = itemBoundingBox.y1;
				plateItem[itemBoundingBox.id].y2 = itemBoundingBox.y2;
			}

			const newPositionAxisRanges = extract2dAxisRanges(itemBoundingBox);

			const subGridNewPosition = AP.util.slice2DArray({
				array: grid,
				rowRange: newPositionAxisRanges.y,
				colRange: newPositionAxisRanges.x,
				isInclusiveEnd: true,
			});

			console.log("before", originalPositionAxisRanges, "after", newPositionAxisRanges);

			if (AP.util.areTwoArraysOfSameDimensions(subGridOriginalPosition, subGridNewPosition)) {
				AP.util.swapElementsOfTwoArrays(subGridOriginalPosition, subGridNewPosition);

				for (let y1 = originalPositionAxisRanges.y.start, y2 = 0; y1 <= originalPositionAxisRanges.y.end; y1++, y2++) {
					for (let x1 = originalPositionAxisRanges.x.start, x2 = 0; x1 <= originalPositionAxisRanges.x.end; x1++, x2++) {
						grid[y1][x1] = subGridOriginalPosition[y2][x2];
					}
				}

				for (let y1 = newPositionAxisRanges.y.start, y2 = 0; y1 <= newPositionAxisRanges.y.end; y1++, y2++) {
					for (let x1 = newPositionAxisRanges.x.start, x2 = 0; x1 <= newPositionAxisRanges.x.end; x1++, x2++) {
						grid[y1][x1] = subGridNewPosition[y2][x2];
					}
				}

				console.table(grid);
			}
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
			// axis: "x",
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

						if (canSwapWithCollidedItem(newBoundingBox, plateGrid)) {
							$draggablePlateItem.removeClass("is-not-swappable");
						} else {
							$draggablePlateItem.addClass("is-not-swappable");
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
						if (canSwapWithCollidedItem(newBoundingBox, plateGrid)) {
							swapPositionsWithCollidingItem(newBoundingBox, plateGrid);
						}
					} else {
						updatePlateItemNewPosition(ui, plateGrid);
					}

					renderGrid(plateGrid);
				}
			},
		});
	};

	return pub;
}());