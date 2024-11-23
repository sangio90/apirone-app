AP.productionTime = AP.productionTime || {};

AP.productionTime.fields = {
    listRoot: $("#production-time-list-root"),
    detailRoot: $("#production-time-detail-modal"),
    detailForm: $("#production-time-detail-form"),
    searchListForm: $("#production-time-grid-search-form"),
    combinationsRoot: $("#production-time-combinations-root")
};

$(document).ready(function (){

	if (AP.productionTime.fields.listRoot.length) {

	    AP.productionTime.list.init();

	}

	if (AP.productionTime.fields.detailRoot.length) {

	    AP.productionTime.detail.init();

	}

});


AP.productionTime.detail = (function () {

	var pub = {};

    var fields = AP.productionTime.fields;

	var defaultDetailForm = {
		data: {
			id: "",
			code: "",
			name: "",
			category: {
                id: ""
            },
			thickness: {
                id: ""
            },
			status: {
				id: "ACT"
			}
		},

        statuses: AP.page.statuses,

		title: "Carica tempo di produzione"
	};

	var fireCallback = function (func) {

		var callbackList = viewModel.get("callback");

		var exists = callbackList?.hasOwnProperty(func);

		if(exists) {

			var thisCallback = callbackList[ func ];

			if(typeof thisCallback == "function") {
				thisCallback();
			}
		}

	};

	var viewModel = kendo.observable({

        detailForm: defaultDetailForm,

        callback: {
			onCreate: undefined,
			onUpdate: undefined,
			onLoad: undefined
		},

		resetForm: function () {

            var detailForm = fields.detailForm;

            var validator = detailForm.validate();
            validator.resetForm();

            detailForm.find(".status").html("");

			viewModel.set("detailForm", defaultDetailForm);
		},

        save: function (event) {

			var detailForm = fields.detailForm;
			var status = detailForm.find(".status");

		    status.html("<img src='assets/main/img/ajax-loading.svg' width=20 height=20>");

			if(detailForm.valid()) {

				NM.util.ajax({
					method: "POST",
					url: "/manager/ajax/lines",
					data: JSON.stringify(viewModel.get("detailForm.data")),
					callback: {
						done: function (xhr) {

							if(xhr.status == "SUCCESS") {

								NM.util.autoHideMessage(status, "<span class='green'>Linea salvata</span>");

								setTimeout(() => $("#line-detail-modal").modal("hide"), 1000);

                                fireCallback("onSave");

							}

						}
					}
				});

			}

            return false;

        },

	});

	pub.new = function ({ onSave }) {

        if (onSave) {
            viewModel.set("callback.onSave", onSave);
        }

        viewModel.resetForm();

        NM.util.openModal( fields.detailRoot);

    },

	pub.edit = function ({ id, onSave }) {

        if (onSave) {
            viewModel.set("callback.onSave", onSave);
        }

        viewModel.resetForm();

        NM.util.ajax({
            method: "GET",
            url: "/manager/ajax/production-times/" + id,
            callback: {
                done: function (xhr) {

                    if(xhr.status == "SUCCESS") {

                        viewModel.set("detailForm.data", xhr.data);
                        viewModel.set("detailForm.title", "Modifica tempo di produzione");

                        NM.util.openModal( fields.detailRoot );

                    }

                }
            }
        });

    },

	pub.init = function () {

        kendo.bind( fields.detailRoot, viewModel);

		var detailForm = fields.detailForm;

		detailForm.validate({
			onfocusout: function (element) {
				$(element).valid();
			},
			rules: {
				code: {
					required: true,
					checkCode: true,
					remote: {
						url: "/manager/ajax/production-times/code-exists",
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


AP.productionTime.list = (function () {

	var pub = {};

    var detailApp = AP.productionTime.detail;
    var fields = AP.productionTime.fields;

	var dataSources = {
		items: NM.kendo.dataSource({ url: "/manager/ajax/production-times" })
	};

	var viewModel = kendo.observable({
		rows: dataSources.items,

        search: function (event) {

            var thisForm = fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read(params);

            return false;

        },

        new: function (event) {

            console.log("detailApp", detailApp);

            var onSave = function () {
                console.log("onSave");
                viewModel.get("rows").read();
            };

            detailApp.new({ onSave: onSave });

            return false;

        },

        edit: function (event) {

            var onSave = function () {
                viewModel.get("rows").read();
            };

            detailApp.edit({ id: event.data.id, onSave: onSave });

            return false;

        },

        delete: function (event) {

			var status = $("#status-delete");
			var checks = $("#production-time-grid").find("[name=selected]:checked");

            console.log("checks", checks);

			if (checks.length) {

				var values = [];

				checks.each(function (){
					values.push($(this).val());
				});

				var ids = values.toString();

				console.log("values", values);
				console.log("ids", ids);

				NM.util.ajax({
					method: "DELETE",
					url: "/manager/ajax/production-times",
					data: ids,
					callback: {
						done: function (xhr) {

							if(xhr.data.payload.hasOwnProperty("errors")) {
								AP.widget.notify("error", "Non riesco a cancellare tutti i valori");
							} else {
								AP.widget.notify("success", "Cancellazione avvenuta con successo");
							}

							var id = viewModel.get("detailForm.data.id");

							viewModel.rows.read();

						}
					}
				});

			} else {

				NM.util.autoHideMessage(status, "<span class='red'>Selezionare almeno un valore</span>");

			}

        },

	});

	pub.init = function () {

        console.log("production-times:list:init");

        kendo.bind( fields.listRoot, viewModel );

	};

    return pub;
}());

