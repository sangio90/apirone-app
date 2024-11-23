AP.component = AP.component || {};

AP.component.fields = {
    rootList: $("#component-list-modal"),
};

$(document).ready(function (){

	if (AP.component.fields.rootList.length) {

		AP.component.list.init();

	}

});


AP.component.list = (function () {

	var pub = {};

	var viewModel = kendo.observable({

		components: [],
		variants: [],
		selected: [],
		colors: [],
		showColors: false,
		showSearchPanel: true,
		variantsTitle: "Varianti",
		currentVariant: {},
		currentComponent: {},

		showSearchResult: function () {

			var ret = viewModel.get("components").length > 0;
			return ret;
		},

		showVariants: function () {

			return !viewModel.get("showSearchPanel");
		},

		useComponent: function (event) {

			var comps = viewModel.get("selected");

			comps.push(event.data);

			viewModel.set("selected", comps);

			return false;
		},

		useColor: function (event) {

			var color = event.data;

			var comp = viewModel.get("currentComponent");
			var variant = viewModel.get("currentVariant");

			var row = {
				comp: {
					id: comp.id,
					name: comp.name
				},
				color: {
					id: color.id,
					name: color.name
				},
				variant: {
					id: variant.id,
					name: variant.name
				}
			};

			console.log("event:useColor", event);

			var comps = viewModel.get("selected");

			comps.push(row);

			viewModel.set("selected", comps);

			return false;
		},

		search: function (event) {

			var thisForm = $("#component-list-search-form");

			console.log("searchComponents");

			var str = thisForm.find("[name=str]").val();
			var status = thisForm.find(".status");

			status.html("Sto cercando...");

            var params = thisForm.serializeJSON();

			NM.util.ajax({
				method: "GET",
				url: "/manager/ajax/components",
				data: params,
				callback: {
					done: function (xhr) {

						if(xhr.status == "SUCCESS") {
							viewModel.set("components", xhr.data);
							status.html("Ho trovato " + xhr.count + " record.");
						}

					}
				}
			});

            return false;

		},

        showComponentsList: function (event) {

			$("#components-list-modal").modal("show");

            return false;
		},

        openColors: function (event) {

			console.log("openColors:event", event);

			viewModel.set("currentVariant", event.data);

			viewModel.set("colors", event.data.colors);

            return false;
		},

        openVariants: function (event) {

			viewModel.set("currentComponent", event.data);

			viewModel.set("showSearchPanel", false);
			viewModel.set("variantsTitle", "Varianti per " + event.data.name + " <small>(" + event.data.id + ")</small>");
			viewModel.set("variants", event.data.variants);

            return false;
		},

        backToComponents: function (event) {

			viewModel.set("showSearchPanel", true);

            return false;
		},

        showVariantsForCount: function (event) {

			return event.variants.length > 0;

		},

        showColorsResult: function (event) {

			$("#components-colors-list-modal").modal("show");

            return false;
		},

	});

	pub.init = function () {

		console.log("component:init");

		kendo.bind(AP.component.fields.rootList, viewModel);

	};

	return pub;

}());