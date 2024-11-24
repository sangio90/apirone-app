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
		// $("#frutto-shuko").kendoDraggable({
		// 	axis: "x",
		// 	hint: function (element) {
		// 		return element.clone();
		// 	}
		// });

		// $("#draggable").data("kendoDraggable").bind("drag", function (e) {
		// 	/* The result can be observed in the DevTools(F12) console of the browser. */
		// 	console.log("x: ", e.screenX, "y: ", e.screenY);
		// });

		// Make the six divs inside the parent draggable
		$(".draggable").draggable({
			containment: "#parent",
			stop: function (event, ui) {
				// Ensure only one section can be dragged at a time
				$(".draggable").draggable("option", "disabled", true);
				$(this).draggable("option", "disabled", false);
			}
		});

		// Make the horizontal draggable div
		$("#horizontal-draggable").draggable({
			axis: "x", // Only allow horizontal dragging
			containment: "#parent",
			grid: [50]
		});


	};

	return pub;
}());