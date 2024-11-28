AP.line = AP.line || {};

AP.line.fields = {
    listRoot: $("#line-list-root"),
    detailRoot: $("#line-detail-modal"),
    detailForm: $("#line-detail-form"),
    searchListForm: $("#line-grid-search-form"),
    combinationsRoot: $("#line-combinations-root")
};

$(document).ready(function (){

	if (AP.line.fields.listRoot.length) {

	    AP.line.list.init();

	}

	if (AP.line.fields.combinationsRoot.length) {

	    AP.line.combinations.init();

	}

	if (AP.line.fields.detailRoot.length) {

	    AP.line.detail.init();

	}

});


AP.line.detail = (function () {

	var pub = {};

    // console.log("categories", AP.page.categories);

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
		categories: AP.page.categories,
		thicknesses: AP.page.thicknesses,

		title: "Carica linea"
	};

	var viewModel = kendo.observable({

        detailForm: defaultDetailForm,

        callback: {
			onCreate: undefined,
			onUpdate: undefined,
			onLoad: undefined
		},

		resetForm: function () {

            var detailForm = AP.line.fields.detailForm;

            var validator = detailForm.validate();
            validator.resetForm();

            detailForm.find(".status").html("");

			viewModel.set("detailForm", defaultDetailForm);
		},

        save: function (event) {

			var detailForm = AP.line.fields.detailForm;
			var status = detailForm.find(".status");

		    status.html("<img src=\"/assets/main/img/ajax-loading.svg\" width=\"20\" height=\"20\">");

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

                                AP.util.fireCallback( "onSave", viewModel.get("callback") );
                                
                                //fireCallback("onSave");

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

        NM.util.openModal(AP.line.fields.detailRoot);

    },

	pub.edit = function ({ id, onSave }) {

        if (onSave) {
            viewModel.set("callback.onSave", onSave);
        }

        viewModel.resetForm();

        NM.util.ajax({
            method: "GET",
            url: "/manager/ajax/lines/" + id,
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

        kendo.bind(AP.line.fields.detailRoot, viewModel);

        AP.page.categories.unshift({ id: "", name: "-- Seleziona una categoria" });
        AP.page.thicknesses.unshift({ id: "", name: "-- Seleziona uno spessore" });

		var detailForm = AP.line.fields.detailForm;

		detailForm.validate({
			onfocusout: function (element) {
				$(element).valid();
			},
			rules: {
				code: {
					required: true,
					checkCode: true,
					remote: {
						url: "/manager/ajax/lines/code-exists",
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


AP.line.list = (function () {

	var pub = {};

    var detailApp = AP.line.detail;

	var dataSources = {
		items: NM.kendo.dataSource({ url: "/manager/ajax/lines" })
	};

	var viewModel = kendo.observable({
		rows: dataSources.items,

        search: function (event) {

            var thisForm = AP.line.fields.searchListForm;

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

			var checks = $("#line-grid").find("[name=selected]:checked");

			if (checks.length) {

				var values = [];

				checks.each(function (){
					values.push($(this).val());
				});

				var ids = values.toString();

				NM.util.ajax({
					method: "DELETE",
					url: "/manager/ajax/lines",
					data: ids,
					callback: {
						done: function (xhr) {

							if(xhr.data.payload.hasOwnProperty("errors")) {
								AP.widget.notify("error", "Non riesco a cancellare tutti i valori");
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

                AP.widget.notify("warning", "Seleziona almeno un valore");

			}

        },

		combinations: function (event) {

            var id = event.data.id;
            window.open("/manager/lines/" + id + "/combinations", "_blank").focus();

            return false;
		},


		attributes: function (event) {

            /*
                note: redirect in controller to first combination
            */

            var id = event.data.id;
            window.open("/manager/lines/" + id + "/attributes", "_blank").focus();

            return false;
		},


	});

	pub.init = function () {

        console.log("list:init");

        kendo.bind(AP.line.fields.listRoot, viewModel);

	};

    return pub;
}());


AP.line.combinations = (function () {

    var pub = {};

    var changeStatus = function (status, event) {

        // active
        var method = "POST";
        var classToShow = "active";
        var classToHide = "deactive";
        var message = "Combinazione salvata";

        // deactive
        if (status == "deactive") {
            method = "DELETE";
            classToShow = "deactive";
            classToHide = "active";
            message = "Combinazione rimossa";
        }

        var status = $("#line-combinations-status");
        var values = $(event.currentTarget).data("values");

        status.html("<img src=\"/assets/main/img/ajax-loading.svg\" width=\"20\" height=\"20\">");

        var size = values.split("__")[0];
        var finish = values.split("__")[1];

        NM.util.ajax({
            method: method,
            url: "/manager/ajax/lines/" + AP.page.line.id + "/combinations",
            data: JSON.stringify({
                    sizeId: size,
                    finishId: finish
                }),
            callback: {
                done: function (xhr) {

                    if(xhr.status == "SUCCESS") {

                        var button = $("button[data-values='" + values +"']");

                        button.filter("." + classToShow).show();
                        button.filter("." + classToHide).hide();

                        status.html("<span class='green'>" + message + "</span> ");

                    }

                }
            }
        });

        return false;

    };

	var viewModel = kendo.observable({

        activate: function (event) {

            event.preventDefault();

            changeStatus("active", event);

		},

        deactivate: function (event) {

            event.preventDefault();

            bootbox.confirm({
                title: "Conferma eliminazione",
                message: "Sei sicuro di voler cancellare questa combinazione?",
                buttons: {
                    confirm: {
                        label: "Si, confermo",
                        className: "btn-primary"
                    },
                    cancel: {
                        label: "No, chiudi",
                        className: "btn-danger"
                    }
                },
                callback: function (result) {
                    if(result) {
                        changeStatus("deactive", event);
                    }
                }
            });
        },


	});

	pub.init = function () {

		kendo.bind(AP.line.fields.combinationsRoot, viewModel);

	};

    return pub;

}());
