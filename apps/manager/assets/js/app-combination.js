AP.combination = AP.combination || {};

AP.combination.fields = {
    rootDetail: $("#combination-detail-root"),
	configRow: $("#combination-config-row"),
	attributeSearchForm: $("#attributes-search-form"),
	attributeModal: $("#combination-attributes-list-modal"),
	imageModal: $("#combination-images-list-modal")
};

$(document).ready(function (){

	if (AP.combination.fields.rootDetail.length) {

		AP.combination.list.init();

	}

});


AP.combination.list = (function () {

	var pub = {};

	var fields = AP.combination.fields;
	var componentApp = AP.component.list;
	var attributeApp = AP.attribute.detail;

	var dataSources = {
		items: NM.kendo.dataSource({ url: "/manager/ajax/combinations/" + AP.page.combinationId + "/items" }),
		attributesList: undefined
	};

	var normalizeComponentItem = function (data) {

		var item = {
			id: 0,
			attribute: {
				id: 0,
				name: ""
			},
			attributeValue: {
				id: 0,
				name: ""
			}
		};

		if (data?.attributeValue) {

			item = {
				id: data.id,
				attribute: {
					id: data.attribute.id,
					name: data.attribute.name
				},
				attributeValue: {
					id: data.attributeValue.id,
					name: data.attributeValue.name
				}
			};

		}

		return item;

	};

	var viewModel = kendo.observable({

		isImagesCompleted: true,
		isImagesUncompleted: false,

		items: dataSources.items,
		attributesList: dataSources.attributesList,

		itemForAttributes: undefined,

		images: [ 
			{ id: "H", name: "Orizzontale" },
			{ id: "V", name: "Verticale" }
		],

		/*
			attributes methods
		*/

		selectAttribute: function (event) {

			var item = viewModel.get("itemForAttributes");
			var parentId = viewModel.get("itemForAttributes.id");

			console.log("selectAttribute:item", item);
			console.log("selectAttribute:parentId", parentId);

			NM.util.ajax({
				method: "POST",
				url: "/manager/ajax/combinations/" + AP.page.combinationId + "/items",
				data: {
					attributeId: event.data.id,
					parentId: viewModel.get("itemForAttributes.id")
				},
				callback: {
					done: function (xhr) {

						viewModel.get("items").read();

						setTimeout(() => fields.attributeModal.modal("hide"), 600);

					},
				}
			});

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

			var checks = $("#combination-items-grid").find("[name=selected]:checked");

			if (checks.length) {

				var values = [];

				checks.each(function (){
					values.push($(this).val());
				});

				var ids = values.toString();

				NM.util.ajax({
					method: "DELETE",
					url: "/manager/ajax/combinations/" + AP.page.combinationId + "/items",
					data: { items: ids },
					callback: {
						done: function (xhr) {

							AP.widget.notify("success", xhr.data.message.text);

							viewModel.items.read();

						}
					}
				});

			} else {

				AP.widget.notify("warning", "Seleziona almeno un attributo");

			}

		},

		openAttributesList: function (event) {

			console.log("openAttributesList:event.data", event.data);

			var item = normalizeComponentItem( event.data );

			console.log("openAttributesList:normalizeComponentItem", item);

			viewModel.set( "itemForAttributes", item );

			NM.util.openModal(fields.attributeModal);

			this.searchAttributes();

		},

		openImagesList: function (event) {

			console.log("openImageList:event.data", event.data);

			NM.util.openModal( fields.imageModal );

			this.searchAttributes();

		},

		openAttributeValues: function (event) {

			// console.log("event.data.id", event.data.id);

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

			viewModel.set("attributesList", dataSource);

            return false;

		},

		/*
			// attributes methods
		*/

        openComponentsList: function (event) {

			var element = $( event.currentTarget );

			if ( !element.attr("data-type") ) {
				console.error("ERROR. Set data-type attribute in currentTarget");
				return;
			}

			var type = element.data("type");

			switch( type ) {
			
				case "lineSize":

					var value = {
						type: "lineSize",
						size: {
							id: element.data("size-id"),
							name: element.data("size-name")
						},
						line: {
							id: element.data("line-id"),
							name: element.data("line-name")
						}
					};
				  
					break;
				
				case "item":

					var value = {
						type: "item",
						item: {
							id: event.data.id
						},
						attribute: {
							id: event.data.attribute.id,
							name: event.data.attribute.name
						},
						attributeValue: {
							id: event.data.attributeValue.id,
							name: event.data.attributeValue.name
						},
					}

					break;
				
				case "combination":

					var value = {
						type: "combination",
						combination: {
							id: element.data("combination-id"),
							name: element.data("combination-name")
						},
					};
			  
					break;
				
				default:
			};

			console.log("openComponentsList:item", value );

			componentApp.open( value );

            return false;
		},

		showItems: function () {

			return viewModel.get("items").view().length ? true : false;

		},

		showImagesList: function () {

			NM.util.openModal($("#combination-images-list-modal"));

		},

		loadFinishes: function () {

			console.log("loadFinishes");

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

			console.log("combinations", combinations);

			combinations.forEach(function (combination) {

				if( lineId == combination.line.id 
						&& sizeId == combination.size.id ) {

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

		console.log("combination:init")

		kendo.bind(fields.rootDetail, viewModel);

		viewModel.loadFinishes();


		initSort();
		
		initUpload();

	};

	var initUpload = function() {

		console.log("initUpload");


		//var documents = viewModel.get( "documents" ).data();
		//var shipmentId = viewModel.get( "shipment.id" );

		var documents = viewModel.get("images");

		if( documents.length > 0 ) {

			var modal = $("#documents-upload-modal");
			modal.modal( "show" );

			for ( var document of documents ) {
			
				var uid = document.uid;

				$("#document-upload-" + uid ).fileupload({
					dropZone: $("#document-upload-dropzone-" + uid),
					autoUpload: true,
					formData: { "shipmentId": 0, "documentTypeId": document.id },
					url: "/manager/ajax/shipment/upload-document",
					add: function (event, data) { 
						var uid = $(event.target).data("uid");
						
						var status = $("#document-upload-status-" + uid );
						
						status.html("");
						
						//TODO: get list form configuration
						if (!(/\.(jpg|jpeg|png|pdf)$/i).test(data.files[0].name)) {
							status.html("<span class='error'>File non ammesso. Consentiti: jpg, jpeg, png, pdf.</span>");
							return false;
						}

						data.submit();

					},
		
					progressall: function( event, data ) {

						var status = $('#document-upload-status-' + uid );
						status.html("");

						var uid = $(event.target).data("uid");
						
						var progress = parseInt(data.loaded / data.total * 100, 10);
						$("#document-upload-progress-" + uid + " .upload-bar").css("width", progress + "%");
						
						status.html("Fatto!");
						
						var row = viewModel.get("documents").getByUid( uid );
						
						row.set("completed", true);

					}
				});		

			}				

		} else {

			viewModel.showPaymentDialog();

		}


	};

	var initSort = function() {

		var table = $("#order-element table");

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

	};

	return pub;

}());