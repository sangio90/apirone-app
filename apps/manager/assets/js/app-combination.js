AP.combination = AP.combination || {};

AP.combination.fields = {
    rootDetail: $("#combination-detail-root"),
	configRow: $("#combination-config-row"),
	attributeSearchForm: $("#attributes-search-form"),
	attributeModal: $("#combination-attributes-list-modal")
};

$(document).ready(function (){

	if (AP.combination.fields.rootDetail.length) {

		AP.combination.list.init();

	}

});


AP.combination.list = (function () {

	var pub = {};

	var fields = AP.combination.fields;
	var attributeApp = AP.attribute.detail;

	var dataSources = {
		items: NM.kendo.dataSource({ url: "/manager/ajax/combinations/" + AP.page.combinationId + "/items" }),
		attributesList: undefined
	};

	var viewModel = kendo.observable({

		items: dataSources.items,
		attributesList: dataSources.attributesList,

		/*
			attributes methods
		*/ 

		selectAttribute: function (event) {

			NM.util.ajax({
				method: "POST",
				url: "/manager/ajax/combinations/" + AP.page.combinationId + "/items",
				data: {
					attributeId: event.data.id
				},
				callback: {
					done: function (xhr) {

						viewModel.get("items").read();

						setTimeout(() => fields.attributeModal.modal("hide"), 800);
	
					},
				}
			});

		},

        showComponents: function (event) {

			$("#component-list-modal").modal("show");

            return false;
		},

		getAttributeName: function (event) {

			console.log("getAttributeName:event", event);

			var text = AP.util.getMainText(event.texts);

			return text.name;

		},

		addAttribute: function (event) {

			attributeApp.new({
				callback: {
					onCreate: function () {
						viewModel.attributesList.read();
					}
				}
			});

			return false;

		},

		removeAttributes: function (event) {

			NM.util.ajax({
				method: "POST",
				url: "/manager/ajax/combinations/" + AP.page.combinationId + "/items",
				data: {
					attributeId: event.data.id
				},
				callback: {
					done: function (xhr) {

						viewModel.get("items").read();
	
					},
				}
			});


			console.log("")

			return false;

		},

		showAttributesList: function () {

			NM.util.openModal( $("#combination-attributes-list-modal") );

			this.searchAttributes();

		},

		showAttributeValues: function (event) {

			console.log("event.data.id", event.data.id);

			attributeApp.edit({
				id: event.data.id,
				callback: {
					onSave: function () {
						viewModel.searchAttributes();
					},
				}
			});

			return false;

		},

		searchAttributes: function (event) {

			var thisForm = fields.attributeSearchForm;
			var params = thisForm.serialize();

			var dataSource = NM.kendo.dataSource({ url: "/manager/ajax/attributes?" + params });

			viewModel.set( "attributesList", dataSource );

            return false;

		},		

		/*
			// attributes methods
		*/ 


		showTable: function () {

			return viewModel.get("items").view().length ? true : false;

		},

		showImagesList: function () {

			NM.util.openModal($("#combination-images-list-modal"));

		},

		searchImages: function (event) {
		},

		initUpload: function () {

			var documents = viewModel.get("documents").data();
			var shipmentId = viewModel.get("shipment.id");

			if(documents.length > 0) {

				var modal = $("#documents-upload-modal");
				modal.modal("show");

				for (var document of documents) {

					var uid = document.uid;

					$("#document-upload-" + uid).fileupload({
						dropZone: $("#document-upload-dropzone-" + uid),
						autoUpload: true,
						formData: { "shipmentId": shipmentId, "documentTypeId": document.id },
						url: "/manager/ajax/shipment/upload-document",
						add: function (event, data) {
							var uid = $(event.target).data("uid");

							var status = $("#document-upload-status-" + uid);

							status.html("");

							// TODO: get list form configuration
							if (!(/\.(jpg|jpeg|png|pdf)$/i).test(data.files[0].name)) {
								status.html("<span class=\"error\">File non ammesso. Consentiti: jpg, jpeg, png, pdf.</span>");
								return false;
							}

							data.submit();

						},

						progressall: function (event, data) {

							var status = $("#document-upload-status-" + uid);
							status.html("");

							var uid = $(event.target).data("uid");

							var progress = parseInt(data.loaded / data.total * 100, 10);
							$("#document-upload-progress-" + uid + " .upload-bar").css("width", progress + "%");

							status.html("Fatto!");

							var row = viewModel.get("documents").getByUid(uid);

							row.set("completed", true);

						}
					});

				}

			} else {

				viewModel.showPaymentDialog();

			}

		},

		loadFishes: function () {

			var thisForm  = AP.combination.fields.configRow;
			var finishEle = thisForm.find("[name=finishId]");
			var sizeEle = thisForm.find("[name=sizeId]");

			var lineId = AP.page.lineId;
			var sizeId = sizeEle.val();
			var combinations = AP.page.combinations;
			var combinationId = AP.page.combinationId;

			finishEle.empty("");

			finishEle.append($("<option>", {
					value: "",
					text : "-- seleziona"
				}));

			finishEle.val("");

			var found = false;

			combinations.forEach(function (combination) {

				if(
					lineId == combination.line.id
					&& sizeId == combination.size.id
				) {

					if (combination.id == combinationId) {
						found = true;
					}

					var opt = $("<option>", {
						value: combination.id,
						text : AP.util.getMainText(combination.finish.texts).name
					});

					finishEle.append(opt);

				}

			});

			found ? finishEle.val(AP.page.combinationId) : "";

            return false;

		},

		change: function (event) {

			var thisId = $(event.currentTarget).val();

			if(thisId != AP.page.combinationId && thisId.length) {

            	window.location.href = "/manager/combinations/" + thisId;

			}

            return false;

		},

    });

	pub.init = function () {

		kendo.bind(AP.combination.fields.rootDetail, viewModel);

		viewModel.loadFishes();

	};

	return pub;

}());