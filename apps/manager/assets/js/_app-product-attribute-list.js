broken;
AP.productAttribute = AP.productAttribute || {};

AP.productAttribute.fields = {
    rootDetail: $("#product-detail-root"),
	imagesModal: $("#product-images-list-modal")
};

$(document).ready(function (){

	if (AP.product.fields.rootDetail.length) {

		AP.productAttribute.list.init();

	}

});


AP.productAttribute.list = (function () {

	var pub = {};

	var fields = AP.productAttribute.fields;

	var dataSources = {
		items: NM.kendo.dataSource({ url: "/manager/ajax/products/" + AP.page.productId + "/items" }),
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
		//attributesList: dataSources.attributesList,

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
				url: "/manager/ajax/products/" + AP.page.productId + "/items",
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

			var checks = $("#product-items-grid").find("[name=selected]:checked");

			if (checks.length) {

				var values = [];

				checks.each(function (){
					values.push($(this).val());
				});

				var ids = values.toString();

				NM.util.ajax({
					method: "DELETE",
					url: "/manager/ajax/products/" + AP.page.productId + "/items",
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

			console.log("openImagesList");

			var element = $( event.currentTarget );

			if ( !element.attr("data-type") ) {
				console.error("ERROR. Set data-type attribute in currentTarget");
				return;
			}

			var type = element.data("type");

			switch( type ) {

				case "productItem":

					var value = {
						type: "item",
						id: event.data.id
					};

					var thisUrl = "/manager/ajax/product-items/" + event.data.id + "/images";

					break;

				case "product":

					var value = {
						type: "product",
						id: AP.page.productId
					};

					var thisUrl = "/manager/ajax/products/" + AP.page.productId + "/images";

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

				case "product":

					var value = {
						type: "product",
						product: {
							id: element.data("product-id"),
							name: element.data("product-name")
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

			NM.util.openModal($("#product-images-list-modal"));

		},

		/*
		loadFinishes: function () {

			console.log("loadFinishes");

			var thisForm  = AP.product.fields.configRow;
			var finishEle = thisForm.find("[name=finishId]");
			var sizeEle = thisForm.find("[name=sizeId]");

			var lineId = AP.page.lineId;
			var sizeId = sizeEle.val();
			var products = AP.page.products;
			var productId = AP.page.productId;

			finishEle.empty("");

			finishEle.append($("<option>", {
					value: "",
					text : "-- seleziona"
				}));

			finishEle.val("");

			var found = false;

			products.forEach(function (product) {

				if( lineId == product.line.id && sizeId == product.size.id ) {

					if (product.id == productId) {
						found = true;
					}

					var opt = $("<option>", {
						value: product.id,
						text : AP.util.getMainText(product.finish.texts).name
					});

					finishEle.append(opt);

				}

			});

			found ? finishEle.val(AP.page.productId) : "";

            return false;

		},
		*/

		change: function (event) {

			var thisId = $(event.currentTarget).val();

			if(thisId != AP.page.productId && thisId.length) {

            	window.location.href = "/manager/products/" + thisId;

			}

            return false;

		},

    });

	pub.init = function () {

		console.log("product:init")

		kendo.bind(fields.rootDetail, viewModel);

		viewModel.loadFinishes();

		//initSort();

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

							console.log("progressall:event", event);
							console.log("progressall:data", data);

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

	return pub;

}());


