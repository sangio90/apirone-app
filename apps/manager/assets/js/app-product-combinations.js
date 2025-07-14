AP.product = AP.product || {};
AP.fields.combination = AP.fields.combination || {};

AP.fields.combination = {
	listRoot: $("#product-combinations-root")
};

$(document).ready(function (){

	if (AP.fields.combination.listRoot.length) {
		AP.product.combination.init();
	}

});

AP.product.combination = (function () {

	var pub = {};

	var dataSources = {
		items: NM.kendo.dataSource({ url: "/manager/ajax/products/" + AP.page.productId + "/combinations" })
	};

	var viewModel = kendo.observable({
		rows: dataSources.items,

		resetForm: function () {
			viewModel.set("detailForm", defaultDetailForm);
		},

		search: function (event) {

			var thisForm = AP.fields.product.searchListForm;

			console.log("searchListForm", thisForm);

			var params = thisForm.serializeJSON();

			console.log("searchListForm:params", params);

			viewModel.rows.read( params );

			return false;

		},

		attributes: function (event) {

            var id = event.data.id;
            window.open("/manager/products/" + id + "/detail", "_blank").focus();

            return false;
		},
	});

	pub.init = function () {
		debugger
		kendo.bind(AP.fields.combination.listRoot, viewModel);

	};

	return pub;
}());
