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

	const PLATE_ITEM_WIDTH_IN_PX = 100;
	const ONE_STEP_WIDTH = PLATE_ITEM_WIDTH_IN_PX / 2;
	const MIN_DISTANCE_BEFORE_DRAGGING = 0;

	// TODO: la funzione deve restituire le coordinate per un array del tipo { start: 0, end: 0 }, oppure { start: 0, end: 1 } per i frutti che occupano piu' spazio
	function parseCurrentPosition(uiElement) {
		return {
			start: uiElement.position.offsetInPx / ONE_STEP_WIDTH,
			end: uiElement.data("element-dimension"),
		};
	}

	pub.init = function () {
		$("#draggable-plate-item").draggable({
			axis: "x",
			containment: "#plate-grid",
			distance: MIN_DISTANCE_BEFORE_DRAGGING,
			grid: [ONE_STEP_WIDTH],
			// revert: true,
			revertDuration: 250,
			start: function(event, ui) {
				console.log("start", event, ui);
			},
			drag: function (event, ui) {
				// TODO: qui bisogna inserire la logica di controllo durante lo spostamento, ovvero, se ci sono degli altri frutti
				// devo capire se posso switch'are le loro posizioni oppure devo mettere indietro il draggable perche' manca la distanza minima
				console.log("drag", ui.position);
				// Solo in questo metodo posso modificare la posizione del draggable con il metodo:
				// ui.position.left = [NUMERO_PIXEL];
			},
			stop: function (event, ui) {
				console.log("stop", event, ui);
				// TODO: la prossima volta
				// const newPositionIndex = parseCurrentPosition(ui);
				// console.log(newPositionIndex);
				// ui.helper.attr("data-start-position-index", newPositionIndex.start);
				// ui.helper.attr("data-end-position-index", newPositionIndex.end);
			},
		});
	};

	return pub;
}());