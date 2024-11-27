AP.productCategory = AP.productCategory || {};

AP.productCategory.fields = {
    listRoot: $("#product-category-list-root")
};

$(document).ready(function (){

	if (AP.productCategory.fields.listRoot.length) {

	    AP.productCategory.list.init();

	}

});

AP.productCategory.list = (function () {

	var pub = {};
	var fields = AP.productCategory.fields;

	var dataSources = {
		items: NM.kendo.dataSource({ url: "/manager/ajax/product-categories" })
	};

	var viewModel = kendo.observable({
		rows: dataSources.items,

        delete: function (event) {

			var checks = $("#product-category-grid").find("[name=selected]:checked");

			if (checks.length) {

				var values = [];

				checks.each(function (){
					values.push($(this).val());
				});

				var ids = values.toString();

				NM.util.ajax({
					method: "DELETE",
					url: "/manager/ajax/product-categories",
					data: ids,
					callback: {
						done: function (xhr) {

							if(xhr.data.payload.hasOwnProperty("errors")) {
								AP.widget.notify("error", "Non riesco a cancellare tutte le categorie");
							} else {
								AP.widget.notify("success", "Cancellazione avvenuta con successo");
							}

							var id = viewModel.get("detailForm.data.id");
							console.log("id", id);

							viewModel.rows.read();

						}
					}
				});

			} else {

				AP.widget.notify("warning", "Devi selezionare almeno una catetoria");

			}

        },

	});

	pub.init = function () {

    	kendo.bind( fields.listRoot, viewModel);

	};

    return pub;
}());
