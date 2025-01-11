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
	var fields = AP.component.fields;

	var ds = new kendo.data.DataSource({ data: [ { name: "Roberto" } ] });

	var dataSources = {
		selected: ds
	};

	var viewModel = kendo.observable({

		components: undefined,
		variants: [],
		selected: dataSources.selected,

		colors: [],
		showColors: false,
		showSearchPanel: true,
		variantsTitle: "Varianti",
		currentVariant: {},
		currentComponent: {},

		currentItem: undefined,

		showSearchResult: function () {

			return viewModel.get("components")?.total() > 0;
		
		},

		resetFilterSelected: function () {

            var thisForm = $("#component-list-selected-form");

            thisForm.find( "input[name=str]" ).val("");

            dataSource.filter( [] );

            dataSource.view();

            return false;
		},

		filterSelected: function () {

            var thisForm = $("#component-list-selected-form");
			var dataSource = viewModel.get("selected");
			
			//dataSource.fetch();
			
			console.log( "data", dataSource );
			console.log( "data", dataSource.data() );

            var str = thisForm.find( "input[name=str]" ).val();
            var typeId = thisForm.find( "select[name=processingTypeId]" ).val();

            var filters = [];

            if ( str.length ) {
                filters.push( { field: "name", operator: "contains", value: str } )
            };

            if ( typeId.length ) {
                filters.push( { field: "typeId", operator: "eq", value: typeId } )
            };

            dataSource.filter( filters );

            dataSource.view();

            return false;
		},

		showVariants: function () {

			console.log("showVariants");

			//viewModel.set("variants", []);
			//viewModel.set("colors", []);

			return !viewModel.get("showSearchPanel");
		},

		useColor: function (event) {

			var color = event.data;

			var comp = viewModel.get("currentComponent");
			var variant = viewModel.get("currentVariant");

			var row = {
				quantity: 1,
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

			console.log("useColor:event", event);

			//var comps = viewModel.get("selected");

			console.log("useColor:dataSource", dataSources.selected );

			dataSources.selected.add( row );

			console.log("total", dataSources.selected.total() );

			//console.log("fetch", dataSources.selected.fetch() );
			console.log("total", dataSources.selected.total() );

			return false;
		},

		search: function (event) {

			var thisForm = $("#component-list-search-form");
			var status = thisForm.find(".status");

			var requestStart = function() {
				status.html("Sto cercando...");
			};

			var requestEnd = function( xhr ) {
				status.html("Ho trovato " + xhr.response.total + " componenti");
			};

            var params = thisForm.serializeJSON();
			
			var dataSource = NM.kendo.dataSource({ 
				url: "/manager/ajax/components", 
				params: params, 
				requestEnd: requestEnd, 
				requestStart: requestStart
			});

			viewModel.set("components", dataSource );
			
            return false;

		},

		save: function (event) {

			var thisForm = $("#component-list-selected-form");
			var status = thisForm.find(".status");

            var params = thisForm.serializeJSON();

			var current = viewModel.get("currentItem");

			NM.util.ajax({
				method: "POST",
				url: "/ajax/combination-items/" + current.id + "/components",
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

		/*
        showComponentsList: function (event) {

			$("#components-list-modal").modal("show");

            return false;
		},
		*/

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

		showSelectedTable: function () {

			console.log("viewModel", viewModel);
			console.log("viewModel:selected", viewModel.get("selected"));
			console.log("viewModel:colors", viewModel.get("colors"));
			
			return viewModel.get("selected").length;
		
		},

		removeComponent: function (event) {

			console.log("removeComponent:event", event);

			viewModel.get("selected").getByUid( event.data.uid );

			return false;

		},

        getCurrentItemName: function (event) {

			var attrName = viewModel.get("currentItem.attribute.name")
					+ " / "
					+ viewModel.get("currentItem.attributeValue.name");

            return attrName;
		},

	});

	pub.setCurrentItem = function (item) {

		viewModel.set("currentItem", item);

	};

	pub.open = function (itemId) {

		console.log("open:itemId", itemId);

		NM.util.ajax({
			method: "GET",
			url: "/manager/ajax/combination-items/" + itemId + "/components",
			callback: {
				done: function (xhr) {

					viewModel.set("selected", xhr.data);

					NM.util.openModal($("#component-list-modal"));

				}
			}
		});

	};

	pub.init = function () {

		console.log("component:init");

		kendo.bind(fields.rootList, viewModel);

	};

	return pub;

}());