AP.product = AP.product || {};
AP.fields.product = AP.fields.product || {};

AP.fields.product = {
	listRoot: $("#product-list-root"),
	detailRoot: $("#product-detail-modal"),
	attributesRoot: $("#product-detail-root"),
	detailForm: $("#product-detail-form"),
	searchListForm: $("#product-grid-search-form"),
};

$(document).ready(function (){

	if (AP.fields.product.listRoot.length) {
		AP.product.list.init();
	}

});

AP.product.list = (function () {

	var pub = {};
	var fields = AP.fields.product;
	var detailApp = AP.product.detail;

	var dataSources = {
		items: NM.kendo.dataSource({ url: "/manager/ajax/products" })
	};

	var defaultDetailForm = {
		data: {
			id: "",
			code: "",
			positionCount: "",
			category: {
				id: 167 //TODO: add dynamic value according to current category
			},
			mainText: {
				id: "",
				name: "",
				lang: {
					id: "IT"
				}
			},
			status: {
				id: "ACT"
			}
		},
		statuses: AP.page.statuses,

		title: "Carica prodotto"
	};

	var viewModel = kendo.observable({
		rows: dataSources.items,
		detailForm: defaultDetailForm,

		resetForm: function () {
			viewModel.set("detailForm", defaultDetailForm);
		},

		search: function (event) {

			var thisForm = AP.fields.product.searchListForm;

			console.log("searchListForm", thisForm);

			var params = thisForm.serializeJSON();

			viewModel.rows.read( params );

			return false;

		},

		attributes: function (event) {

            var id = event.data.id;
            window.open("/manager/products/" + id + "/detail", "_blank").focus();

            return false;
		},

		new: function (event) {

			var onSave = function () {
				viewModel.rows.read()
			};

			console.log("event", event.data.id)

			detailApp.new( onSave )

			/*

			var onSave = function () {
				viewModel.rows.read()
			};

			this.resetForm();

			NM.util.openModal( fields.detailRoot );
			*/

		},

		edit: function( event ) {

			var onSave = function () {
				viewModel.rows.read()
			};

			console.log("event", event.data.id)

			detailApp.edit( event.data.id, onSave )

			return false;

		},

        delete: function (event) {

			var checks = $("#product-grid").find("[name=selected]:checked");

			if (checks.length) {

				var values = [];

				checks.each(function (){
					values.push($(this).val());
				});

				var ids = values.toString();

				NM.util.ajax({
					method: "DELETE",
					url: "/manager/ajax/products",
					data: ids,
					callback: {
						done: function (xhr) {

							if(xhr.data.payload.hasOwnProperty("errors")) {
								AP.widget.notify("error", "Non riesco a cancellare tutti i frutti");
							} else {
								AP.widget.notify("success", "Cancellazione avvenuta con successo");
							}

							var id = viewModel.get("detailForm.data.id");

							viewModel.rows.read();

						}
					}
				});

			} else {

				AP.widget.notify("warning", "Selezionare almeno un frutto");

			}

        }

	});

	pub.init = function () {

		kendo.bind(AP.fields.product.listRoot, viewModel);

	};

	return pub;
}());
