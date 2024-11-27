AP.lineCategory = AP.lineCategory || {};

AP.lineCategory.fields = {
    listRoot: $("#product-category-list-root")
};

$(document).ready(function (){

	if (AP.lineCategory.fields.listRoot.length) {

	    AP.lineCategory.list.init();

	}

});

AP.lineCategory.list = (function () {

	var pub = {};

	var dataSources = {
		items: NM.kendo.dataSource({ url: "/manager/ajax/lines/categories" })
	};

	var viewModel = kendo.observable({
		rows: dataSources.items,
	});

	pub.init = function () {

		console.log("lineCategories");

    	kendo.bind(AP.lineCategory.fields.listRoot, viewModel);

	};

    return pub;
}());
