AP.combination = AP.combination || {};

AP.combination.fields = {
	rootDetail: $("#combination-detail-root"),
	configRow: $("#combination-config-row"),
	attributeSearchForm: $("#attributes-search-form"),
	attributeModal: $("#combination-attributes-list-modal"),
	imagesModal: $("#combination-images-list-modal"),
	reorderingModal: $("#combination-sorting-modal"),
	fruitItemsImagesModal: $("#fruit-items-combinations-images-modal"),
};

$(document).ready(function () {
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
		items: NM.kendo.dataSource({
			url:
				"/manager/ajax/combinations/" +
				AP.page.combinationId +
				"/items",
		}),
		orderingItems: NM.kendo.dataSource({
			url:
				"/manager/ajax/combinations/" +
				AP.page.combinationId +
				"/items/order",
		}),
		orderingAttributes: NM.kendo.dataSource({
			url:
				"/manager/ajax/combinations/" +
				AP.page.combinationId +
				"/attributes/order",
		}),
		attributesList: undefined,
	};

	var normalizeComponentItem = function (data) {
		var item = {
			id: 0,
			attribute: {
				id: 0,
				name: "",
			},
			attributeValue: {
				id: 0,
				name: "",
			},
		};

		if (data?.attributeValue) {
			item = {
				id: data.id,
				attribute: {
					id: data.attribute.id,
					name: data.attribute.name,
				},
				attributeValue: {
					id: data.attributeValue.id,
					name: data.attributeValue.name,
				},
			};
		}

		return item;
	};

	var viewModel = kendo.observable({
		items: dataSources.items,
		orderingItems: dataSources.orderingItems,
		attributesList: dataSources.attributesList,
		orderingAttributes: dataSources.orderingAttributes,

		itemForAttributes: undefined,

		images: undefined,
		currentImageEntity: undefined,
		currentUploadUrl: undefined,

		/*
			attributes methods
		*/

		getImageTypeText: function (event) {
			var text = AP.util.getMainText(event.type.texts.toJSON());

			return text.name + " " + event.shortId;
		},

		getImageSrc: function (event) {
			var uri = event.uri;

			if (event.uri != "") {
				var replaced = uri.replace("_ori", "500");

				return replaced;
			}

			return "/assets/main/img/img-not-found.png";
		},

		getImageHref: function (event) {
			var uri = event.uri;

			if (event.uri != "") {
				//console.log("event.uri", event.uri);
				return uri;
			}

			// TODO: not work with target=_blank
			return "javascript:void(0)";
		},

		selectAttribute: function (event) {
			NM.util.ajax({
				method: "POST",
				url:
					"/manager/ajax/combinations/" +
					AP.page.combinationId +
					"/items",
				data: {
					attributeId: event.data.id,
					parentId: viewModel.get("itemForAttributes.id"),
				},
				callback: {
					done: function (xhr) {
						viewModel.get("items").read();

						setTimeout(
							() => fields.attributeModal.modal("hide"),
							600
						);
					},
				},
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
					},
				},
			});

			return false;
		},

		removeAttributes: function (event) {
			var checks = $("#combination-items-grid").find(
				"[name=selected]:checked"
			);

			if (checks.length) {
				var values = [];

				checks.each(function () {
					values.push($(this).val());
				});

				var ids = values.toString();

				NM.util.ajax({
					method: "DELETE",
					url:
						"/manager/ajax/combinations/" +
						AP.page.combinationId +
						"/items",
					data: { items: ids },
					callback: {
						done: function (xhr) {
							AP.widget.notify("success", xhr.data.message.text);

							viewModel.items.read();
						},
					},
				});
			} else {
				AP.widget.notify("warning", "Seleziona almeno un attributo");
			}
		},

		openAttributesList: function (event) {
			//console.log("openAttributesList");

			var item = normalizeComponentItem(event.data);

			viewModel.set("itemForAttributes", item);

			NM.util.openModal(fields.attributeModal);

			this.searchAttributes();

			return false;
		},

		addValue: function (event) {
			//console.log("addValue", event.data );

			NM.util.ajax({
				method: "POST",
				url:
					"/manager/ajax/combinations/" +
					AP.page.combinationId +
					"/values",
				data: JSON.stringify(event.data),
				callback: {
					done: function (xhr) {
						viewModel.get("items").read();

						//setTimeout(() => fields.attributeModal.modal("hide"), 600);

						AP.widget.notify("success", xhr.data.message.text);
					},
				},
			});

			return false;
		},

		openReorderingModal: function (event) {
			NM.util.openModal(fields.reorderingModal);

			return false;
		},

		openFruitItemsImagesModal: function (event) {
			NM.util.openModal(fields.fruitItemsImagesModal);

			return false;
		},

		openImagesList: function (event) {
			/*
			console.log("openImagesList");

			productAttributeApp.openImagesList();

			return false;
			*/

			//console.log("openImagesList");

			var element = $(event.currentTarget);

			if (!element.attr("data-type")) {
				console.error(
					"ERROR. Set data-type attribute in currentTarget"
				);
				return;
			}

			var type = element.data("type");

			switch (type) {
				case "combinationItem":
					var value = {
						type: "item",
						id: event.data.id,
					};

					var thisUrl =
						"/manager/ajax/combination-items/" +
						event.data.id +
						"/images";

					break;

				case "combination":
					var value = {
						type: "combination",
						id: AP.page.combinationId,
					};

					var thisUrl =
						"/manager/ajax/combinations/" +
						AP.page.combinationId +
						"/images";

					break;

				default:
					console.error(
						"ERROR. Type [" + type + "] for image not found"
					);
			}

			var dataSource = NM.kendo.dataSource({ url: thisUrl });

			viewModel.set("currentImageEntity", value);
			viewModel.set("currentUploadUrl", thisUrl);
			viewModel.set("images", dataSource);

			initUpload();

			return false;
		},

		openAttributeValues: function (event) {
			//console.log("openAttributeValues");

			attributeApp.edit({
				id: event.data.id,
				callback: {
					onSave: function () {
						viewModel.searchAttributes();
					},
				},
			});

			return false;
		},

		searchAttributes: function (event) {
			var thisForm = fields.attributeSearchForm;
			var params = thisForm.serialize();

			var dataSource = NM.kendo.dataSource({
				url: "/manager/ajax/attributes?" + params,
			});

			viewModel.set("attributesList", dataSource);

			return false;
		},

		/*
			// attributes methods
		*/

		openComponentsList: function (event) {
			console.log("comb:openComponentsList", event);

			var element = $(event.currentTarget);

			if (!element.attr("data-type")) {
				console.error(
					"ERROR. Set data-type attribute in currentTarget"
				);
				return;
			}

			var type = element.data("type");

			switch (type) {
				case "lineSize":
					var value = {
						type: "lineSize",
						size: {
							id: element.data("size-id"),
							name: element.data("size-name"),
						},
						line: {
							id: element.data("line-id"),
							name: element.data("line-name"),
						},
					};

					break;

				case "item":
					var value = {
						type: "item",
						item: {
							id: event.data.id,
						},
						attribute: {
							id: event.data.attribute.id,
							name: event.data.attribute.name,
						},
						attributeValue: {
							id: event.data.attributeValue.id,
							name: event.data.attributeValue.name,
						},
					};

					break;

				case "combination":
					var value = {
						type: "combination",
						combination: {
							id: element.data("combination-id"),
							name: element.data("combination-name"),
						},
					};

					break;

				default:
			}

			//console.log("openComponentsList:item", value );

			componentApp.open(value);

			return false;
		},

		showItems: function () {
			return viewModel.get("items").view().length ? true : false;
		},

		showImagesList: function () {
			NM.util.openModal($("#combination-images-list-modal"));
		},

		loadSizes: function () {
			//console.log("loadFinishes:x");

			var thisForm = AP.combination.fields.configRow;

			var finishEle = thisForm.find("[name=finishId]");
			var sizeEle = thisForm.find("[name=sizeId]");

			//console.log("finishEle", finishEle);

			var lineId = AP.page.lineId;
			var sizeId = sizeEle.val();
			var finishId = finishEle.val();

			var combinations = AP.page.combinations;
			var combinationId = AP.page.combinationId;

			sizeEle.empty("");

			sizeEle.append(
				$("<option>", {
					value: "",
					text: "-- seleziona",
				})
			);

			sizeEle.val("");

			var found = false;

			combinations.forEach(function (combination) {
				if (
					lineId == combination.line.id &&
					finishId == combination.finish.id
				) {
					if (combination.id == combinationId) {
						found = true;
					}

					var opt = $("<option>", {
						value: combination.id,
						//text : AP.util.getMainText( combination.size.texts ).name
						text: combination.size.code,
					});

					sizeEle.append(opt);
				}
			});

			found ? sizeEle.val(AP.page.combinationId) : "";

			return false;
		},

		change: function (event) {
			var thisId = $(event.currentTarget).val();

			if (thisId != AP.page.combinationId && thisId.length) {
				window.location.href = "/manager/combinations/" + thisId;
			}

			return false;
		},
	});

	pub.init = function () {
		//console.log("combination:init");

		kendo.bind(fields.rootDetail, viewModel);

		viewModel.loadSizes();

		initSorts();
	};

	var initUpload = function () {
		var images = viewModel.get("images");

		var thisUrl = viewModel.get("currentUploadUrl");

		NM.util.openModal(fields.imagesModal);

		//console.log("total", images.total() );

		// it shouldn't be needed "fetch"
		images
			.fetch()
			.then(function () {
				if (images.total() > 0) {
					//console.log("total:in", images.total() );

					for (var image of images.data()) {
						var uid = image.uid;

						//console.log( "image", image );

						$("#image-upload-" + uid).fileupload({
							dropZone: $("#image-upload-dropzone-" + uid),
							autoUpload: true,
							formData: {
								typeId: image.type.id,
								imageId: image.id,
							},
							url: thisUrl,
							add: function (event, data) {
								var uid = $(event.target).data("uid");

								var status = $("#image-upload-status-" + uid);

								status.html("");

								//TODO: get list form configuration
								if (
									!/\.(jpg|jpeg|png|pdf)$/i.test(
										data.files[0].name
									)
								) {
									status.html(
										"<span class='error'>File non ammesso. Consentiti: jpg, jpeg, png, pdf.</span>"
									);
									return false;
								}

								data.submit();
							},

							success: function (event, data) {
								//TODO
								console.log("success");
								console.log("success", data);
							},

							progressall: function (event, data) {
								var status = $("#image-upload-status-" + uid);
								status.html("");

								var uid = $(event.target).data("uid");

								var progress = parseInt(
									(data.loaded / data.total) * 100,
									10
								);
								$(
									"#image-upload-progress-" +
										uid +
										" .upload-bar"
								).css("width", progress + "%");

								status.html("Fatto!");

								var row = viewModel.get("images").getByUid(uid);

								setTimeout(() => {
									initUpload();
								}, "1000");
							},
						});
					}
				}
			})
			.catch((error) => {
				console.error(error);
			});
	};

	var initSorts = function () {
		initItemsSort();
		initAttributesSort();
	};

	var getSortablePlaceholder = function (element) {
		return element
			.clone()
			.addClass("sortable-placeholder")
			.height(element.height())
			.width(element.width());
	};

	var getSortableHint = function (element) {
		var ele = $("<div>");
		var text = $(element).find("td.sortable").text();

		ele.text(text)
			.height(element.height())
			.width(element.width())
			.addClass("sortable-hint");

		return ele;
	};

	var refreshDatasources = function () {
		viewModel.get("items").read();
		viewModel.get("orderingItems").read();
		viewModel.get("orderingAttributes").read();
	};

	var sortableChanged = function (entity, widget) {
		var status = $(".tab-status");
		status.html(
			"<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>"
		);

		var items = widget.items();
		var ids = [];

		for (var item of items) {
			var id = $(item).data("id");
			ids.push($(item).data("id"));
		}

		NM.util.ajax({
			method: "POST",
			url:
				"/manager/ajax/combinations/" +
				AP.page.combinationId +
				"/" +
				entity +
				"/order",
			data: JSON.stringify(ids),
			callback: {
				done: function (xhr) {
					refreshDatasources();
					NM.util.autoHideMessage(
						status,
						"<span class='green'>Ordinamento salvato.</span>"
					);
				},
			},
		});
	};

	var initItemsSort = function () {
		var table = $("#combination-ordering-items-grid table");

		table.kendoSortable({
			axis: "y",
			filter: ">tbody >tr",
			hint: function (element) {
				return getSortableHint(element);
			},
			placeholder: function (element) {
				return getSortablePlaceholder(element);
			},

			move: function (event) {
				var item = {};
				var target = {};

				var itemEle = $(event.item);
				var targetEle = $(event.target);

				var place = $(".sortable-placeholder");

				item.attribute = itemEle.data("attribute");
				item.level = itemEle.data("level");

				target.attribute = targetEle.data("attribute");
				target.level = targetEle.data("level");

				if (
					item.attribute == target.attribute &&
					item.level == target.level
				) {
					place
						.removeClass("sortable-placeholder-unavailable")
						.addClass("sortable-placeholder-available");
				} else {
					place
						.removeClass("sortable-placeholder-available")
						.addClass("sortable-placeholder-unavailable");
				}

				return;
			},

			change: function () {
				sortableChanged("items", this);
			},

			end: function (event) {
				var items = viewModel.get("orderingItems");

				var item = items.at(event.oldIndex);
				var target = items.at(event.newIndex);

				console.log("item", item);
				console.log("target", target);

				console.log("item.level", item.level);
				console.log("target.level", target.level);

				console.log("event.newIndex", event.newIndex);
				console.log("event.oldIndex", event.oldIndex);

				if (
					item.attribute.id != target.attribute.id ||
					item.level != target.level ||
					event.newIndex == event.oldIndex
				) {
					console.log("can't");
					event.preventDefault();
				}

				return;
			},
		});
	};

	var initAttributesSort = function () {
		var table = $("#combination-ordering-attributes-grid table");

		table.kendoSortable({
			axis: "y",
			filter: ">tbody >tr",
			hint: function (element) {
				return getSortableHint(element);
			},
			placeholder: function (element) {
				return getSortablePlaceholder(element);
			},

			move: function (event) {
				var place = $(".sortable-placeholder");

				var itemEle = $(event.item);
				var targetEle = $(event.target);

				var itemLevel = itemEle.data("level");
				var targetLevel = targetEle.data("level");

				if (itemLevel == targetLevel) {
					place
						.removeClass("sortable-placeholder-unavailable")
						.addClass("sortable-placeholder-available");
				} else {
					place
						.removeClass("sortable-placeholder-available")
						.addClass("sortable-placeholder-unavailable");
				}

				return;
			},

			change: function () {
				sortableChanged("attributes", this);
			},

			end: function (event) {
				var items = viewModel.get("orderingAttributes");

				var item = items.at(event.oldIndex);

				var target = items.at(event.newIndex);

				if (
					item.level != target.level ||
					event.newIndex == event.oldIndex
				) {
					console.log("can't");
					event.preventDefault();
				}

				return;
			},
		});
	};	

	return pub;
})();
