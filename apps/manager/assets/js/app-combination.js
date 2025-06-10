AP.combination = AP.combination || {};

AP.combination.fields = {
    rootDetail: $("#combination-detail-root"),
	configRow: $("#combination-config-row"),
	attributeSearchForm: $("#attributes-search-form"),
	attributeModal: $("#combination-attributes-list-modal"),
	imagesModal: $("#combination-images-list-modal"),
	reorderingModal: $("#combination-reordering-modal"),
	fruitItemsImagesModal: $("#fruit-items-combinations-images-modal")
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

		items: dataSources.items,
		attributesList: dataSources.attributesList,

		itemForAttributes: undefined,

		images: undefined,
		currentImageEntity: undefined,
		currentUploadUrl: undefined,

		/*
			attributes methods
		*/

		getImageTypeText: function( event ) {

			var text = AP.util.getMainText( event.type.texts.toJSON() );

			return text.name + " " + event.shortId;
		},

		getImageSrc: function( event ) {

			var uri = event.uri;

			if( event.uri != "" ) {
				var replaced = uri.replace("_ori", "500");

				return replaced;
			}

			return "/assets/main/img/img-not-found.png";
		},

		getImageHref: function( event ) {

			var uri = event.uri;

			if( event.uri != "" ) {
				console.log("event.uri", event.uri);
				return uri;
			}

			// TODO: not work with target=_blank
			return "javascript:void(0)";
		},

		selectAttribute: function (event) {

			//console.log("selectAttribute");

			//var item = viewModel.get("itemForAttributes");
			//var parentId = viewModel.get("itemForAttributes.id");

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

			console.log("openAttributesList");

			var item = normalizeComponentItem( event.data );

			viewModel.set( "itemForAttributes", item );

			NM.util.openModal( fields.attributeModal );

			this.searchAttributes();

			return false;

		},

		openReorderingModal: function (event) {

			NM.util.openModal( fields.reorderingModal );

			return false;

		},

		openFruitItemsImagesModal: function (event) {

			NM.util.openModal( fields.fruitItemsImagesModal );

			return false;

		},

		openImagesList: function (event) {

			/*
			console.log("openImagesList");

			productAttributeApp.openImagesList();

			return false;
			*/

			console.log("openImagesList");

			var element = $( event.currentTarget );

			if ( !element.attr("data-type") ) {
				console.error("ERROR. Set data-type attribute in currentTarget");
				return;
			}

			var type = element.data("type");

			switch( type ) {

				case "combinationItem":

					var value = {
						type: "item",
						id: event.data.id
					};

					var thisUrl = "/manager/ajax/combination-items/" + event.data.id + "/images";

					break;

				case "combination":

					var value = {
						type: "combination",
						id: AP.page.combinationId
					};

					var thisUrl = "/manager/ajax/combinations/" + AP.page.combinationId + "/images";

					break;

				default:
					console.error("ERROR. Type [" + type + "] for image not found");
			};

			var dataSource = NM.kendo.dataSource({ url: thisUrl });

			viewModel.set( "currentImageEntity", value );
			viewModel.set( "currentUploadUrl", thisUrl );
			viewModel.set( "images", dataSource );

			initUpload();

			return false;

		},

		openAttributeValues: function (event) {

			console.log("openAttributeValues");

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

			console.log("comb:openComponentsList", event);

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
					};

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

		loadSizes: function () {

			console.log("loadFinishes:x");

			var thisForm  = AP.combination.fields.configRow;

			var finishEle = thisForm.find("[name=finishId]");
			var sizeEle = thisForm.find("[name=sizeId]");

			console.log("finishEle", finishEle);

			var lineId = AP.page.lineId;
			var sizeId = sizeEle.val();
			var finishId = finishEle.val();

			var combinations = AP.page.combinations;
			var combinationId = AP.page.combinationId;

			sizeEle.empty("");

			sizeEle.append($("<option>", {
				value: "",
				text : "-- seleziona"
			}));

			sizeEle.val("");

			var found = false;

			combinations.forEach( function(combination) {

				if( lineId == combination.line.id && sizeId == combination.size.id ) {

					if (combination.id == combinationId) {
						found = true;
					}

					var opt = $("<option>", {
						value: combination.id,
						text : AP.util.getMainText( combination.size.texts ).name
					});

					sizeEle.append( opt );

				}

			});

			found ? sizeEle.val( AP.page.combinationId ) : "";

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

		console.log("combination:init");

		kendo.bind(fields.rootDetail, viewModel);

		viewModel.loadSizes();

		initSort();

	};

	var initUpload = function() {

		var images = viewModel.get("images");

		var thisUrl = viewModel.get("currentUploadUrl");

		NM.util.openModal( fields.imagesModal );

		console.log("total", images.total() );

		// it shouldn't be needed "fetch"
		images.fetch().then( function() {

			if( images.total() > 0 ) {

				console.log("total:in", images.total() );

				for ( var image of images.data() ) {

					var uid = image.uid;

					console.log( "image", image );

					$("#image-upload-" + uid ).fileupload({
						dropZone: $("#image-upload-dropzone-" + uid),
						autoUpload: true,
						formData: { "typeId": image.type.id, "imageId": image.id },
						url: thisUrl,
						add: function (event, data) { 
							var uid = $(event.target).data("uid");

							var status = $("#image-upload-status-" + uid );

							status.html("");

							//TODO: get list form configuration
							if (!(/\.(jpg|jpeg|png|pdf)$/i).test(data.files[0].name)) {
								status.html("<span class='error'>File non ammesso. Consentiti: jpg, jpeg, png, pdf.</span>");
								return false;
							}

							data.submit();

						},

						success: function( event, data ) {
							//TODO
							console.log("success")
							console.log("success", data)
						},

						progressall: function( event, data ) {

							var status = $( "#image-upload-status-" + uid );
							status.html("");

							var uid = $(event.target).data("uid");

							var progress = parseInt(data.loaded / data.total * 100, 10);
							$("#image-upload-progress-" + uid + " .upload-bar").css("width", progress + "%");

							status.html("Fatto!");

							var row = viewModel.get("images").getByUid( uid );

							setTimeout(() => {

								initUpload();

							}, "1000");

						}
					});

				}

			}

		} )
			.catch( error => { console.error( error ) } );
	};

	var initSort = function() {

		var table = $("#combination-ordering-items-grid table");

		table.kendoSortable({
			axis: "y",
			filter: ">tbody >tr",
			hint: function (element) {
				var ele = $("<div>");
				var text = $(element).find("td.sortable").text();

				ele.text(text)
					.height( element.height() )
					.width( element.width() )
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

				console.log("combination");

				console.log("event.oldIndex", event.oldIndex);
				console.log("event.newIndex", event.newIndex);

				console.log("end:event", event);

				var id = AP.page.combinationId;
				var status = $("#combination-reordering-status");

				//$("#combination-reordering-status").html("<span class='green'>Salvato!</span>");

				NM.util.autoHideMessage(status, "<span class='green'>Ordinamento salvato.</span>");

				//console.log("data", viewModel.get("items").data() );

				if(event.newIndex != event.oldIndex) {

					NM.util.ajax({
						method: "POST",
						url: "/manager/ajax/attributes/" + id + "/values/order",
						data: JSON.stringify( viewModel.get("items").data() ),
						callback: {
							done: function (xhr) {

								NM.util.autoHideMessage(status, "<span class='green'>Ordinamento salvato.</span>");
							}
						}
					});

					/*
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
						data: JSON.stringify( viewModel.get("detailForm.data.values").data() ),
						callback: {
							done: function (xhr) {

								NM.util.autoHideMessage(status, "<span class='green'>Ordinamento salvato.</span>");
							}
						}
					});

					*/

				}
			}

		});

	};

	return pub;

}());