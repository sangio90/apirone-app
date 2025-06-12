AP.attribute = AP.attribute || {};
AP.fields.attribute = AP.fields.attribute || {};

AP.fields.attribute.list = {
    listRoot  : $("#attribute-list-root"),
    searchForm: $("#attribute-grid-search-form")
};

$(document).ready(function (){

	if (AP.fields.attribute.list.listRoot.length) {

		AP.attribute.list.init();

	}

});

AP.attribute.list = (function () {

	console.log("AP.attribute.detail", AP.attribute)

	var fields = AP.fields.attribute.list;
	var detailApp = AP.attribute.detail;

	var pub = {};

	var dataSources = {
		rows: NM.kendo.dataSource({ url: "/manager/ajax/attributes" })
	};

	var viewModel = kendo.observable({

		rows: dataSources.rows,

		new: function () {

			var onCreate = function () {
				viewModel.rows.read();
				console.log("new: AGGIORNO LE RIGHE");
			};

			detailApp.new( onCreate );

			return false;

		},

		edit: function (event) {

			var onUpdate = function () {
				viewModel.rows.read();
				console.log("new: AGGIORNO LE RIGHE");
			};

			console.log("edit: ", event.data.id);

			detailApp.edit( event.data.id, onUpdate );

			return false;

		},

		search: function () {

			var thisForm = fields.searchForm;

			var params = thisForm.serializeJSON();

			viewModel.rows.read(params);

			return false;


		},

        delete: function (event) {

			var checks = $("#attribute-grid").find("[name=selected]:checked");

			if (checks.length) {

				var values = [];

				checks.each(function (){
					values.push($(this).val());
				});

				var ids = values.toString();

				NM.util.ajax({
					method: "DELETE",
					url: "/manager/ajax/attributes",
					data: ids,
					callback: {
						done: function (xhr) {

							if(xhr.data.payload.hasOwnProperty("errors")) {
								AP.widget.notify("error", "Non riesco a cancellare tutti i valori");
							} else {
								AP.widget.notify("success", "Cancellazione avvenuta con successo");
							}

							viewModel.rows.read();

						}
					}
				});

			} else {

				AP.widget.notify("warning", "Selezionare almeno un attributo");

			}

        },

    });

	pub.init = function () {

		console.log("AP.attribute.list:init");

		kendo.bind( fields.listRoot, viewModel );

	};

	return pub;

}());


