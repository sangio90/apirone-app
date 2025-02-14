AP.fruit = AP.fruit || {};
AP.fields.fruit = AP.fields.fruit || {};

AP.fields.fruit = {
	detailRoot: $("#fruit-detail-root"),

	attributeSearchForm: $("#attributes-search-form"),
	attributeModal: $("#combination-attributes-list-modal"),

};

$(document).ready(function (){

	if (AP.fields.fruit.detailRoot.length) {

		AP.fruit.attribute.init();

	}

});

AP.fruit.list = (function () {

	var pub = {};
	var fields = AP.fields.fruit;

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

			var thisForm = AP.fields.fruit.searchListForm;

			console.log("searchListForm", thisForm);

			var params = thisForm.serializeJSON();

			console.log("searchListForm:params", params);

			viewModel.rows.read( params );

			return false;

		},

		attributes: function (event) {

            var id = event.data.id;
            window.open("/manager/fruits/" + id + "/detail", "_blank").focus();

            return false;
		},

		save: function (event) {

			var thisForm = AP.fields.fruit.detailForm;
			var status = thisForm.find(".status");

			status.html("<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>");

			if(thisForm.valid()) {

				NM.util.ajax({
					method: "POST",
					url: "/manager/ajax/fruits",
					data: JSON.stringify( viewModel.get("detailForm.data") ),
					callback: {
						done: function (xhr) {

							if( xhr.status == "SUCCESS" ) {

								viewModel.get("rows").read();
								NM.util.autoHideMessage( status, "<span class='green'>Dimensione salvata</span>" );

								setTimeout( () => fields.detailRoot.modal("hide"), 1500 );

							}

						}
					}
				});

			}

			return false;

		},

		new: function (event) {

			this.resetForm();

			NM.util.openModal( fields.detailRoot );

		},

		edit: function (event) {

			console.log("edit");

			viewModel.set("detailForm.data", event.data);
			viewModel.set("detailForm.title", "Modifica frutto < " + event.data.code + " >");

			NM.util.openModal( fields.detailRoot );

			return false;

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

		kendo.bind(AP.fields.fruit.listRoot, viewModel);

		var detailForm = AP.fields.fruit.detailForm;
		
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
				},
				positionsCount: {
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
					maxlength: "Al massimo 3 caratteri",
					checkCode: "Solo numeri, lettere, trattino o trattino basso",
					remote: "Il codice esiste"
				},
				positionsCount: {
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

AP.fruit.attribute = (function () {

	var pub = {};
	var fields = AP.fields.fruit;

	var componentApp = AP.component.list;
	var attributeApp = AP.attribute.detail;

	var dataSources = {
		items: NM.kendo.dataSource({ url: "/manager/ajax/fruits" })
	};

	var viewModel = kendo.observable({
		rows: dataSources.items,

		openComponentsList: function (event) {

			var element = $( event.currentTarget );

			if ( !element.attr("data-type") ) {
				console.error("ERROR. Set data-type attribute in currentTarget");
				return;
			}

			var type = element.data("type");

			switch( type ) {

				case "fruit":

					var value = {
						type: "fruit",
						fruit: {
							id: element.data("size-id"),
							name: element.data("size-name")
						},
					};

					break;

				case "fruitItem":

					var value = {
						type: "fruitItem",
					};

					break;

				default:
			};

			console.log("openComponentsList:item", value );

			componentApp.open( value );

            return false;
		},		

		save: function (event) {

			var thisForm = AP.fields.fruit.detailForm;
			var status = thisForm.find(".status");

			status.html("<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>");

			if(thisForm.valid()) {

				NM.util.ajax({
					method: "POST",
					url: "/manager/ajax/fruits",
					data: JSON.stringify( viewModel.get("detailForm.data") ),
					callback: {
						done: function (xhr) {

							if( xhr.status == "SUCCESS" ) {

								viewModel.get("rows").read();
								NM.util.autoHideMessage( status, "<span class='green'>Dimensione salvata</span>" );

								setTimeout( () => fields.detailRoot.modal("hide"), 1500 );

							}

						}
					}
				});

			}

			return false;

		},

		new: function (event) {
		},

		edit: function (event) {
		},

        delete: function (event) {
        },

		searchAttributes: function (event) {

			var thisForm = fields.attributeSearchForm;
			var params = thisForm.serialize();

			var dataSource = NM.kendo.dataSource({ url: "/manager/ajax/attributes?" + params });

			viewModel.set("attributesList", dataSource);

            return false;

		},

		openAttributesList: function (event) {

			//var item = normalizeComponentItem( event.data );

			//viewModel.set( "itemForAttributes", item );

			NM.util.openModal( fields.attributeModal );

			this.searchAttributes();

			return false;

		},

	});

	pub.init = function () {

		console.log("AP.fruit.attribute:init")

		kendo.bind( AP.fields.fruit.detailRoot, viewModel );

	};

	return pub;
}());

