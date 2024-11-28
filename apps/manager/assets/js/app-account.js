AP.account = AP.account || {};

AP.account.fields = {
    listRoot: $("#account-list-root"),
    detailRoot: $("#account-detail-modal"),
    detailForm: $("#account-detail-form"),
    searchListForm: $("#account-grid-search-form")
};

$(document).ready(function (){

	if (AP.account.fields.listRoot.length) {

	    AP.account.list.init();

	}

	if (AP.account.fields.detailRoot.length) {

	    AP.account.detail.init();

	}

});


AP.account.detail = (function () {

    var pub = {};
    var fields = AP.account.fields;

	var defaultDetailForm = {
		data: {
			id: "",
			name: "",
			phone: "",
			email: "",
			status: {
				id: "ACT"
			},
			lang: {
				id: "IT"
			},
			selectedRoles: []
		},

        statuses: AP.page.statuses,
        roles: AP.page.roles,
        langs: AP.page.langs,

		title: "Carica account"
	};

	var viewModel = kendo.observable({
        detailForm: defaultDetailForm,

		resetForm: function () {

            var detailForm = fields.detailForm;

            console.log("fields.detailForm", fields.detailForm);

            var validator = detailForm.validate();
            validator.resetForm();

            detailForm.find(".status").html("");

			viewModel.set("detailForm", defaultDetailForm);
		},

        callback: {
			onCreate: undefined,
			onUpdate: undefined,
			onLoad: undefined
		},

        getCreatedAt: function (event) {

            return NM.kendo.formatDate( event.createdAt );

		},

		print: function (item) {

            window.open("/manager/account/print", "_blank");

            return false;
		},


	});

	pub.new = function ({ onSave }) {

        if (onSave) {
            viewModel.set("callback.onSave", onSave);
        }

        viewModel.resetForm();

        NM.util.openModal(AP.account.fields.detailRoot);

    },

	pub.edit = function ({ id, onSave }) {

        if (onSave) {
            viewModel.set("callback.onSave", onSave);
        }

        viewModel.resetForm();

        NM.util.ajax({
            method: "GET",
            url: "/manager/ajax/accounts/" + id,
            callback: {
                done: function (xhr) {

                    if(xhr.status == "SUCCESS") {

                        viewModel.set("detailForm.data", xhr.data);
                        viewModel.set("detailForm.title", "Modifica linea");

                        NM.util.openModal(AP.line.fields.detailRoot);

                    }

                }
            }
        });

    },
	pub.init = function () {

        console.log("account:detail:init");

		kendo.bind(fields.detailRoot, viewModel);

		var detailForm = fields.detailForm;

		detailForm.validate({
			onfocusout: function (element) {
				$(element).valid();
			},
			rules: {
				email: {
					required: true,
					email: true,
					remote: {
						url: "/manager/ajax/accounts/email-exists",
						data: { id: function () { return  viewModel.get("detailForm.data.id"); } },
						dataFilter: function (xhr) {
							var json = JSON.parse(xhr);
							return json.data == false;
						}
					}
				}
			},
			messages: {
				email: {
					required: "Email richiesta",
					checkCode: "Email non valida",
					remote: "L'email è già in uso"
				}
			},

		});

	};

    return pub;

}());


AP.account.list = (function () {

	var pub = {};

    var detailApp = AP.account.detail;
    var fields = AP.account.fields;

	var dataSources = {
		items: NM.kendo.dataSource({ url: "/manager/ajax/accounts" })
	};

	var viewModel = kendo.observable({
		rows: dataSources.items,

        getCreatedAt: function (event) {

            return NM.kendo.formatDate(event.createdAt);

		},

        search: function (event) {

            console.log("search");

            var thisForm = fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read(params);

            return false;

        },

        new: function (event) {

            console.log("detailApp", detailApp);

            var onSave = function () {
                viewModel.get("rows").read();
            };

            detailApp.new({ onSave: onSave });

            NM.util.openModal(AP.account.fields.detailRoot);

        },

		print: function (item) {

            window.open("/manager/lines/print", "_blank");

            return false;
		},

        delete: function (event) {

			var checks = $("#account-grid").find("[name=selected]:checked");

			if (checks.length) {

				var values = [];

				checks.each(function (){
					values.push($(this).val());
				});

				var ids = values.toString();

				NM.util.ajax({
					method: "DELETE",
					url: "/manager/ajax/accounts",
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

				AP.widget.notify("warning", "Seleziona almeno un account");

			}

        },

	});

	pub.init = function () {

        kendo.bind(fields.listRoot, viewModel);

	};

    return pub;
}());