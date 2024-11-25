AP.attribute = AP.attribute || {};
AP.fields.attribute = AP.fields.attribute || {};

AP.fields.attribute.detail = {
    detailRoot: $("#attribute-detail-modal"),
    detailForm: $("#attribute-detail-form"),
    valueForm : $("#attribute-values-add-form"),
    valuesForm: $("#attribute-values-form")
};   

$(document).ready(function (){

	if (AP.fields.attribute.detail.detailRoot.length) {

		AP.attribute.detail.init();

	}

});

/*
	detail
*/

AP.attribute.detail = (function () {

	var pub = {};
    
    var fields = AP.fields.attribute.detail;

	var defaults = {

		detailForm: {
			data: {
				status: {
					id: "ACT"
				},
				id: "",
				orderBy: 0,
				selectedCategories: [],
				mainText: {
					id: "",
					name: "",
					lang: {
						id: "IT"
					}
				}
			},
			title: "Carica attributo",
			action: "create"
		},

		valueForm: {
			data: {
				status: {
					id: "ACT"
				},
				id: "",
				orderBy: 0,
				mainText: {
					id: "",
					name: "",
					lang: {
						id: "IT"
					}
				}
			},

			labelButton: "Carica"
		},

	};

	var viewModel = kendo.observable({

		detailForm: defaults.detailForm,
		valueForm: defaults.valueForm,

		categories: AP.page.categories,
		statusList: AP.page.attributeStatusList,

		callback: {
			onCreate: undefined,
			onUpdate: undefined,
			onLoad: undefined,
			onUpdateValue: undefined,
			onCreateValue: undefined
		},

		getFormValueTitle: function() {

			var data = viewModel.get("valueForm.data");
			var values = viewModel.get("detailForm.data.values");


			if ( data.id ) {
				
				return "Modifica valore < " + data.id + " >";
			
			} else {
				
				if ( values?.total() == 0 ) {
					
					return "Carica il primo valore";
				
				} else {

					return "Carica valore";
				
				}
			}
		},


		isUpdate: function() {

			console.log("isUpdate", viewModel.get("detailForm.data.id").length)

			return viewModel.get("detailForm.data.id").length;
		},

		// TODO: only one "resetForm"
		resetDetailForm: function () {

			var thisForm = AP.attribute.fields.detailForm;

			viewModel.set("detailForm", defaults.detailForm);

			thisForm.find(".status").html("");
			thisForm.data("validator").resetForm();

			$("#attribute-nav-values-but").removeClass("disabled");

		},

		resetValueForm: function () {

			var thisForm = AP.attribute.fields.valueForm;

			viewModel.set("valueForm", defaults.detailForm);

			thisForm.find(".status").html("");
			thisForm.data("validator").resetForm();

		},

		isValuesGridVisible: function () {

			var values = viewModel.get("detailForm.data.values");

			if (values?.total()) {
				return true;
			}

			return false;

		},

		deleteValues: function (event) {

			var status = $("#attribute-values-delete-status");
			var checks = $("#attribute-values-form").find("[name=selected]:checked");

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
					url: "/manager/ajax/attributes/values",
					data: ids,
					callback: {
						done: function (xhr) {

							if(xhr.data.payload.hasOwnProperty("errors")) {

								AP.widget.notify("error", "Non sonosciuto a cancellare tutti i valori");

							} else {

								AP.widget.notify("success", "Cancellazione avvenuta con successo");

							}

							var id = viewModel.get("detailForm.data.id");
							console.log("id", id);

							loadAttribute({ id: viewModel.get("detailForm.data.id") });

						}
					}
				});

			} else {

				NM.util.autoHideMessage(status, "<span class='red'>Selezionare almeno un valore</span>");

			}

		},

		editValue: function (event) {

			console.log("editValue:event", event);

			viewModel.set("valueForm.data", event.data);
			viewModel.set("valueForm.title", "Modifica valore < " + event.data.id + " >");
			viewModel.set("valueForm.labelButton", "Aggiorna");

		},

		save: function () {

			var thisForm = AP.attribute.fields.detailForm;
			var status = thisForm.find(".status");

			status.html("<img src='/assets/main/img/ajax-loading.svg' width=20 height=20>");

			if(thisForm.valid()) {

				var data = viewModel.get("detailForm.data");

				NM.util.ajax({
					method: "POST",
					url: "/manager/ajax/attributes",
					data: JSON.stringify( data ),
					callback: {
						done: function (xhr) {

							var callback = viewModel.isUpdate() ? "onUpdate" : "onCreate";

							NM.util.autoHideMessage(status, "<span class='green'>" + xhr.data.message.text + "</span>");

							console.log("callback", callback);
							console.log("save:id", data.get("id"));
							
							setTimeout(() => {

								if ( !viewModel.isUpdate() ) {

									var onLoad = function() {

										var tab = $("#attribute-nav-values-but");
	
										tab.removeClass("disabled");
										tab.tab("show");
	
									}
	
									viewModel.set("callback.onLoad", onLoad);

								}

								loadAttribute( { id: xhr.data.payload.id } );

							}, 700);

							AP.util.fireCallback( callback, viewModel.get("callback") );

						}
					}
				});

			}

			return false;

		},

		newValue: function () {

			viewModel.resetValueForm();

		},


		saveValue: function () {

			var thisForm = AP.attribute.fields.valueForm;
			var status = $("#attribute-values-add-form-status");

			var attrId = viewModel.get("detailForm.data.id");

			if(thisForm.valid()) {

				status.html("<img src='/assets/main/img/ajax-loading.svg' width=20 height=20>");

				NM.util.ajax({
					method: "POST",
					url: "/manager/ajax/attributes/values",
					data: JSON.stringify({
							value: viewModel.get("valueForm.data"),
							attributeId: attrId
						}),
					callback: {
						done: function (xhr) {

							NM.util.autoHideMessage(status, "<span class='green'>Valore salvato</span>");

							var id = viewModel.get("detailForm.data.id");
							console.log("id", id);

							loadAttribute({id: id});

							AP.util.fireCallback( "onUpdateValue", viewModel.get("callback") );

						}
					}
				});

			}

			return false;

		},

    });

	loadAttribute = function ({ id }) {

		NM.util.ajax({
			method: "GET",
			url: "/manager/ajax/attributes/" + id,
			callback: {
				done: function (xhr) {

					var selectedCategories = [];

					if( xhr.data?.categories ) {
						for (var category of xhr.data.categories )  {
							selectedCategories.push(category);
						}
					}

					var valuesDataSource = new kendo.data.DataSource({
						data: xhr.data.values,
						sort: { field: "orderBy", dir: "asc" }
					});

					delete xhr.data.values;

					viewModel.set("detailForm.data", xhr.data);
					viewModel.set("detailForm.data.selectedCategories", selectedCategories);
					viewModel.set("detailForm.data.values", valuesDataSource);
					viewModel.set("detailForm.title", "Modifica attributo <" + xhr.data.name + " >");
					//viewModel.set("detailForm.labelButton", "Aggiorna");


					AP.util.fireCallback( "onLoad", viewModel.get("callback") );

					NM.util.openModal($("#attribute-detail-modal"));

					var table = $("#attribute-values-grid .k-grid-container .k-table");

					table.kendoSortable({
						axis: "y",
						filter: ">tbody >tr",
						hint: function (element) {
							var ele = $("<div>");
							var text = $(element).find("td.sortable").text();

							ele.text(text)
								.height(element.height())
								.width(element.width())
								.addClass("sortable-hint");

							return ele;

						},
						placeholder: function (element) {
							return element.clone()
								.addClass("sortable-placeholder")
								.height(element.height())
								.width(element.width());
						},

						end: function (event) {

							console.log("event.oldIndex", event.oldIndex);
							console.log("event.newIndex", event.newIndex);

							if(event.newIndex != event.oldIndex) {

								var values = viewModel.get("detailForm.data.values").data();
								var thisForm = $("#attribute-values-form");
								var status = thisForm.find(".status");

								console.log("values", values.length);

								// INFO: kendo send an extra item to remove accordingly to direction of d&d
								if (event.oldIndex < event.newIndex) {
									var removeItem = event.oldIndex;
								} else {
									var removeItem = event.oldIndex+1;
								}

								status.html("<img src='/assets/main/img/ajax-loading.svg' width=20 height=20>");

								var count = 1;

								table.find("tr").each(function (index) {

									if (index != removeItem) {

										var ele = $(this);
										var uid = ele.data("uid");

										for(var value of values) {

											if (value.get("uid") == uid) {

												value.set("orderBy", count*10);
											}
										}

										count++;

									}

								});

								NM.util.ajax({
									method: "POST",
									url: "/manager/ajax/attributes/" + id + "/values/order",
									data: JSON.stringify(viewModel.get("detailForm.data.values").data()),
									callback: {
										done: function (xhr) {

											NM.util.autoHideMessage(status, "<span class='green'>Ordinamento salvato.</span>");
										}
									}
								});

							}
						}

					});
				}
			}
		});
	};

    pub.new = function ( callback ) {

		viewModel.resetValueForm();
		viewModel.resetDetailForm();

		$("#attribute-nav-values-but").addClass("disabled");

		NM.util.openModal( $("#attribute-detail-modal") );

		return;

	};


    pub.edit = function ({ id  }) {

		loadAttribute({ id: id  });

    };

	pub.init = function () {

		console.log("AP.attribute.detail:init");

		kendo.bind( fields.detailRoot, viewModel);

        console.log("fields", fields)

		var valueForm = fields.valueForm;
		var detailForm = fields.detailForm;

		detailForm.validate({
			onfocusout: function (element) {
				$(element).valid();
			},
			rules: {
				attr: {
					required: true
				}
			},
			messages: {
				attr: {
					required: "Descrizione principale richiesta",
				},
			},

		});

		// console.log("valueForm", valueForm);

		valueForm.validate({
			onfocusout: function (element) {
				$(element).valid();
			},
			rules: {
				newValueName: {
					required: true,
				},
				code: {
					checkCode: true,
					required: true,
					maxlength: 5,
					remote: {
						url: "/manager/ajax/attributes/values/code-exists",
						data: { id: function () { return  viewModel.get("valueForm.data.id"); } },
						dataFilter: function (xhr) {
							var json = JSON.parse(xhr);
							return json.data == false;
						}
					}
				},
				newValueStatus: {
					required: true
				}
			},
			messages: {
				newValueName: {
					required: "Descrizione richiesta",
				},
				code: {
					required: "Codice richiesto",
					checkCode: "Solo numeri, lettere, trattino o trattino basso",
					remote: "Il codice esiste",
					max: "Al massimo 5 caratteri"
				},
				newValueStatus: {
					required: "Stato richiesto",
				},
			},

		});

	};

	return pub;

}());
