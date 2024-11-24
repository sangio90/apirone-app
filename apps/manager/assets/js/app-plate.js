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
		$("#draggable-plate-item").draggable({
			axis: "x", // Only allow horizontal dragging
			containment: "#plate-grid",
			grid: [50]
		});
	};

	return pub;
}());