AP.fruit = AP.fruit || {};

AP.fruit.fields = {
	listRoot: $("#fruit-list-root"),
	detailForm: $("#fruit-detail-form"),
	searchListForm: $("#fruit-grid-search-form")
};

$(document).ready(function (){

	if (AP.fruit.fields.listRoot.length) {

		AP.fruit.list.init();

	}

});

AP.fruit.list = (function () {

	var pub = {};

	var dataSources = {
		items: NM.kendo.dataSource({ url: "/manager/ajax/fruits" })
	};

	var defaultDetailForm = {
		data: {
			id: "",
			code: "",
			positionsCount: "",
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

		title: "Carica frutto"
	};

	var viewModel = kendo.observable({
		rows: dataSources.items,
		detailForm: defaultDetailForm,

		resetForm: function () {
			viewModel.set("detailForm", defaultDetailForm);
		},

		search: function (event) {

			var thisForm = AP.fruit.fields.searchListForm;

			console.log("searchListForm", thisForm)
			
			var params = thisForm.serializeJSON();
			
			console.log("params", params)

			viewModel.rows.read(params);

			return false;

		},

		save: function (event) {

			var thisForm = AP.fruit.fields.detailForm;
			var status = thisForm.find(".status");

			status.html('<img src="/assets/main/img/ajax-loading.svg" width="20" height="20">');

			if(thisForm.valid()) {

				NM.util.ajax({
					method: "POST",
					url: "/manager/ajax/fruits",
					data: JSON.stringify(viewModel.get("detailForm.data")),
					callback: {
						done: function (xhr) {
							
							if( xhr.status == "SUCCESS" ) {

								viewModel.get("rows").read();
								NM.util.autoHideMessage( status, "<span class='green'>Dimensione salvata</span>" );

								setTimeout( () => $("#fruit-detail-modal").modal("hide"), 1500 );

							}

						}
					}
				});

			}

			return false;

		},

		new: function (event) {

			this.resetForm();

			NM.util.openModal($("#fruit-detail-modal"));

		},

		edit: function (event) {

			console.log("edit");

			viewModel.set("detailForm.data", event.data);
			viewModel.set("detailForm.title", "Modifica frutto < " + event.data.code + " >");

			NM.util.openModal( $("#fruit-detail-modal") );

		},

        delete: function (event) {

			var checks = $("#fruit-grid").find("[name=selected]:checked");

			if (checks.length) {

				var values = [];

				checks.each(function (){
					values.push($(this).val());
				});

				var ids = values.toString();

				NM.util.ajax({
					method: "DELETE",
					url: "/manager/ajax/fruits",
					data: ids,
					callback: {
						done: function (xhr) {

							if(xhr.data.payload.hasOwnProperty("errors")) {
								AP.widget.notify("error", "Non riesco a cancellare tutte le dimensioni");
							} else {
								AP.widget.notify("success", "Cancellazione avvenuta con successo");
							}

							var id = viewModel.get("detailForm.data.id");

							viewModel.rows.read();

						}
					}
				});

			} else {

				AP.widget.notify("warning", "Selezionare almeno una dimensione");

			}

        },		

	});

	pub.init = function () {

		kendo.bind(AP.fruit.fields.listRoot, viewModel);

		var detailForm = AP.fruit.fields.detailForm;

		detailForm.validate({
			onfocusout: function (element) {
				$(element).valid();
			},
			rules: {
				code: {
					required: true,
					maxlength: 10,
					checkCode: true,
					remote: {
						url: "/manager/ajax/fruits/code-exists",
						data: { id: function () { return  viewModel.get("detailForm.data.id"); } },
						dataFilter: function (xhr) {
							var json = JSON.parse(xhr);
							return json.data == false;
						}
					}
				}
			},
			messages: {
				code: {
					required: "Codice richiesto",
					maxlength: "Al massimo 3 caratteri",
					checkCode: "Solo numeri, lettere, trattino o trattino basso",
					remote: "Il codice esiste"
				}
			},

		});

	};

	return pub;
}());

