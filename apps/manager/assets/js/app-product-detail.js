AP.product = AP.product || {};
AP.fields.product = AP.fields.product || {};

AP.fields.product = {
	detailRoot: $("#product-detail-modal"),
	detailForm: $("#product-detail-form"),
};

$(document).ready(function (){

	if (AP.fields.product.detailRoot.length) {

		AP.product.detail.init();

	}

});

AP.product.detail = (function () {

	var pub = {};

	var fields = AP.fields.product;

	var defaultDetailForm = {
		data: {
			shortId: "",
			id: "",
			code: "",
			name: "",
			mainText: {
				name: ""
			},
			category: {
                id: ""
            },
			status: {
				id: "ACT"
			}
		},

        statuses: AP.page.statuses,
		title: "Carica prodotto"
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

		    status.html("<img src='/assets/main/img/ajax-loading.svg' width=20 height=20>");

			viewModel.set("detailForm.data.category.id", 167);

			if(detailForm.valid()) {

				NM.util.ajax({
					method: "POST",
					url: "/manager/ajax/products",
					data: JSON.stringify( viewModel.get("detailForm.data") ),
					callback: {
						done: function (xhr) {

							if(xhr.status == "SUCCESS") {

								NM.util.autoHideMessage(status, "<span class='green'>Prodotto salvata</span>");

								setTimeout(() => $("#line-detail-modal").modal("hide"), 1000);

                                AP.util.fireCallback( "onSave", viewModel.get("callback") );

							}

						}
					}
				});

			}

            return false;

        },

	});

	pub.new = function ( onSave ) {

        if (onSave) {
            viewModel.set("callback.onSave", onSave);
        }

        viewModel.resetForm();

        NM.util.openModal( fields.detailRoot );

    },

	pub.edit = function ( id, onSave ) {

		console.log("pub.edit:id", id)

        if (onSave) {
            viewModel.set("callback.onSave", onSave);
        }

        viewModel.resetForm();

        NM.util.ajax({
            method: "GET",
            url: "/manager/ajax/products/" + id,
            callback: {
                done: function (xhr) {

                    if(xhr.status == "SUCCESS") {

						console.log("fields.detailRoot", fields.detailRoot);

						viewModel.set("detailForm.data", xhr.data);
						viewModel.set("detailForm.title", "Modifica prodotto < " + xhr.data.code + " >");

                        NM.util.openModal( fields.detailRoot );

                    }

                }
            }
        });

    },

	pub.init = function () {

        kendo.bind( fields.detailRoot, viewModel);

		var detailForm = fields.detailForm;

		console.log("detailForm",detailForm );
		
		detailForm.validate({
			onfocusout: function (element) {
				$(element).valid();
			},
			rules: {
				code: {
					required: true,
					maxlength: 20,
					checkCode: true,
					remote: {
						url: "/manager/ajax/products/code-exists",
						data: { id: function () { return  viewModel.get("detailForm.data.id"); } },
						dataFilter: function (xhr) {
							var json = JSON.parse(xhr);
							return json.data == false;
						}
					}
				},
				positionCount: {
					required: true,
					digits: true
				},
				name: {
					required: true,
				},
				statusId: {
					required: true,
				}
			},
			messages: {
				code: {
					required: "Codice richiesto",
					maxlength: "Al massimo 20 caratteri",
					checkCode: "Solo numeri, lettere, trattino o trattino basso",
					remote: "Il codice esiste"
				},
				positionCount: {
					required: "Numero posizioni richieste",
					digits: "Richiesto un valore intero"
				},
				name: {
					required: "Descrizione richiesta",
				},
				statusId: {
					required: "Status richiesto",
				}
			},

		});		

	};

    return pub;
}());
