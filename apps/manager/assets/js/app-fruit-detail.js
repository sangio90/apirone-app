AP.fruit = AP.fruit || {};
AP.fields.fruit = AP.fields.fruit || {};

AP.fields.fruit = {
	detailRoot: $("#fruit-detail-root"),

	attributeSearchForm: $("#attributes-search-form"),
	attributeModal: $("#combination-attributes-list-modal"),

};

$(document).ready(function (){

	if (AP.fields.fruit.detailRoot.length) {

		AP.fruit.detail.init();

	}

});

AP.fruit.detail = (function () {

	var pub = {};
	var fields = AP.fields.fruit;

	var componentApp = AP.component.list;

	var dataSources = {
		items: NM.kendo.dataSource({ url: "/manager/ajax/fruits/" + AP.page.fruitId + "/items" }),
	};

	var viewModel = kendo.observable({
		items: dataSources.items,
		itemForAttributes: {
			id: 0
		},

		openComponentsList: function (event) {

			var element = $( event.currentTarget );

			if ( !element.attr("data-type") ) {
				console.error("ERROR. Set data-type attribute in currentTarget");
				return;
			}

			var type = element.data("type");

			console.log( "element", element);

			switch( type ) {

				case "fruit":

					var value = {
						type: "fruit",
						fruit: {
							id: element.data("fruit-id"),
							code: element.data("fruit-code")
						},
					};

					break;

				case "fruitItem":

					var value = {
						type: "fruitItem",
					};

					break;

				default:
			};

			console.log("openComponentsList:item", value );

			componentApp.open( value );

            return false;
		},

		searchAttributes: function (event) {

			var thisForm = fields.attributeSearchForm;
			var params = thisForm.serialize();

			var dataSource = NM.kendo.dataSource({ url: "/manager/ajax/attributes?" + params });

			viewModel.set("attributesList", dataSource);

            return false;

		},

		openAttributesList: function (event) {

			var element = $( event.currentTarget );

			var itemId = element.attr("data-parent-id");

			viewModel.set( "itemForAttributes.id", itemId );

			NM.util.openModal( fields.attributeModal );

			this.searchAttributes();

			return false;

		},

		selectAttribute: function (event) {

			console.log( "selectAttribute:event", event );

			NM.util.ajax({
				method: "POST",
				url: "/manager/ajax/fruits/" + AP.page.fruitId + "/items",
				data: {
					fruitId: AP.page.fruitId,
					attributeId: event.data.id,
					parentId: viewModel.get("itemForAttributes.id")
				},
				callback: {
					done: function (xhr) {

						viewModel.get("items").read();

						setTimeout(() => fields.attributeModal.modal("hide"), 600);

					},
				}
			});

		},


	});

	pub.init = function () {

		console.log("AP.fruit.detail:init");

		kendo.bind( AP.fields.fruit.detailRoot, viewModel );

	};

	return pub;
}());

