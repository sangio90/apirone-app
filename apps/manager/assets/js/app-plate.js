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
			};

			result.x2 = result.x1 + result.width;
			result.y2 = result.y1 + result.height;

			return result;
		}

		function isColliding(box, grid) {
			let result = false;

			// Broad phase
			const xAxis = { start: box.x1, end: box.x2 };
			const yAxis = { start: box.y1, end: box.y2 };
			const gridSection = plateGrid.slice(yAxis.start, yAxis.end).map(inner => inner.slice(xAxis.start, xAxis.end));
			const possibleBoxes = {};
			for (const row of gridSection) {
				for (const cell of row) {
					if (cell != box.id && cell != CELL_TYPES.EMPTY) {
						if (!possibleBoxes.hasOwnProperty(cell)) {
							possibleBoxes[cell] = pageData.PLATE_ELEMENTS[cell];
						}
					}
				}
			}

			// Narrow phase
			for (const [key, candidateBox] of Object.entries(possibleBoxes)) {
				if (
					candidateBox.x1 <= box.x2 && candidateBox.x2 >= box.x1
					&&
					candidateBox.y1 <= box.y2 && candidateBox.y2 >= box.y1
				) {
					result = true;

					break;
				}
			}

			return result;
		}

		function canSwap(box, grid) {
			let result = false;

			return result;
		}

		$(".draggable-plate-item").draggable({
			// axis: "x",
			containment: "#plate-grid",
			distance: MIN_DISTANCE_BEFORE_DRAGGING,
			grid: [CELL_SIZE_IN_X, CELL_SIZE_IN_Y],
			// revert: true,
			revertDuration: 250,
			start: function(event, ui) {
				// console.log("start", event, ui);

				ui.helper.addClass("is-dragging");
			},
			drag: function (event, ui) {
				// TODO: qui bisogna inserire la logica di controllo durante lo spostamento, ovvero, se ci sono degli altri frutti
				// devo capire se posso switch'are le loro posizioni oppure devo mettere indietro il draggable perche' manca la distanza minima
				// Solo in questo metodo posso modificare la posizione del draggable con il metodo:
				// ui.position.left = [NUMERO_PIXEL];

				const newBoundingBox = parseBoundingBox(ui);
				// console.log(newBoundingBox.x1, newBoundingBox.x2, newBoundingBox.y1, newBoundingBox.y2);

				if (isColliding(newBoundingBox, plateGrid)) {
					ui.helper.addClass("is-colliding");

					if (canSwap(newBoundingBox, plateGrid)) {
						console.log("can swap");

						ui.helper.removeClass("is-not-swappable");
						// swapWithCollidingBox(newBoundingBox);
					} else {
						ui.helper.addClass("is-not-swappable");
					}
				} else {
					ui.helper.removeClass("is-colliding");
				}
			},
			stop: function (event, ui) {
				// console.log("stop", event, ui);

				// TODO: devo aggiornare la plateGrid, se le coordinate finali sono diverse da quelle di partenza
				ui.helper.removeClass("is-dragging");
				ui.helper.removeClass("is-not-swappable");
			},
		});
	};

	return pub;
}());