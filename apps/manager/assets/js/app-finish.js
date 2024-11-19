AP.finish = AP.finish || {};

AP.finish.fields = {
	listRoot: $("#finish-list-root"),
	detailForm: $("#finish-detail-form"),
	searchListForm: $("#finish-grid-search-form")
};

$(document).ready(function (){

	if (AP.finish.fields.listRoot.length) {

		AP.finish.list.init();

	}

});

AP.finish.list = (function () {

	var pub = {};

	var dataSources = {
		items: NM.kendo.dataSource({ url: "/manager/ajax/finishes" })
	};

	var defaultDetailForm = {
		data: {
			id: "",
			code: "",
			name: "",
			selectedCategories: [],
			status: {
				id: "ACT"
			}
		},
		statuses: AP.page.statuses,
		categories: AP.page.categories,

		title: "Carica finitura"
	};


	var viewModel = kendo.observable({
		rows: dataSources.items,
		detailForm: defaultDetailForm,

		resetForm: function () {
			viewModel.set("detailForm", defaultDetailForm);
		},

		search: function (event) {

			var thisForm = AP.finish.fields.searchListForm;

			var params = thisForm.serializeJSON();

			viewModel.rows.read(params);

			return false;

		},

		save: function (event) {

			var thisForm = AP.finish.fields.detailForm;
			var status = thisForm.find(".status");

			status.html("<img src=\"/assets/main/img/ajax-loading.svg\" width=\"20\" height=\"20\">");
			// var attrId = viewModel.get( "detailForm.data.id" )

			if(thisForm.valid()) {

				NM.util.ajax({
					method: "POST",
					url: "/manager/ajax/finishes",
					data: JSON.stringify(viewModel.get("detailForm.data")),
					callback: {
						done: function (xhr) {

							status.html("<span class='green'>Finitura salvata</span> ");

							setTimeout(() => $("#finish-detail-modal").modal("hide"), 1000);

						}
					}
				});

			}

			return false;

		},

		new: function (event) {

			this.resetForm();

			NM.util.openModal($("#finish-detail-modal"));

		},

		edit: function (event) {

			viewModel.set("detailForm.data", event.data);
			viewModel.set("detailForm.title", "Modifica finitura < " + event.data.code + " >");

			var selectedCategories = [];

			for (var category of event.data.categories)  {
				selectedCategories.push(category.id);
			}

			viewModel.set("detailForm.data.selectedCategories", selectedCategories);

			NM.util.openModal($("#finish-detail-modal"));

		},

	});

	pub.init = function () {

		kendo.bind(AP.finish.fields.listRoot, viewModel);

		var detailForm = AP.finish.fields.detailForm;

		detailForm.validate({
			onfocusout: function (element) {
				$(element).valid();
			},
			rules: {
				code: {
					required: true,
					checkCode: true,
					remote: {
						url: "/manager/ajax/finishes/code-exists",
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
					checkCode: "Solo numeri, lettere, trattino o trattino basso",
					remote: "Il codice esiste"
				}
			},

		});

	};

	return pub;
}());

