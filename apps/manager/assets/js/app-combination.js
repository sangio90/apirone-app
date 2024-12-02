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
	var componentApp = AP.component.list;
	var attributeApp = AP.attribute.detail;

	var dataSources = {
		items: NM.kendo.dataSource({ url: "/manager/ajax/combinations/" + AP.page.combinationId + "/items" }),
		attributesList: undefined
	};

	var normalizeComponentItem = function( data ) {

		var item = {
			attribute: {
				id: 0,
				name: ""
			},
			attributeValue: {
				id: 0,
				name: ""
			}
		}

		console.log("data?.attributeValue", data?.attributeValue)

		if ( data?.attributeValue ) {

			item = {
				attribute: {
					id: data.attribute.id,
					name: data.attribute.name
				},
				attributeValue: {
					id: data.attributeValue.id,
					name: data.attributeValue.name
				}
			}

		}

		return item;

	}

	var viewModel = kendo.observable({

		items: dataSources.items,
		attributesList: dataSources.attributesList,

		itemForAttributes: undefined,


		/*
			attributes methods
		*/ 

		selectAttribute: function (event) {

			var parentId = viewModel.get("itemForAttributes.id");
			console.log("parentId", parentId);

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

							AP.widget.notify("success", xhr.data.message.text );

							viewModel.items.read();

						}
					}
				});

			} else {

				AP.widget.notify( "warning", "Seleziona almeno un attributo" );

			}

		},

		showAttributesList: function (event) {

			var item = normalizeComponentItem( event.data );

			//console.log("normalizeComponentItem", item);

			viewModel.set("itemForAttributes", item);

			NM.util.openModal( fields.attributeModal );

			this.searchAttributes();

		},

		showAttributeValues: function (event) {

			//console.log("event.data.id", event.data.id);

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


        showComponentsList: function (event) {

			componentApp.open( event.data.id );
			componentApp.setCurrentItem( event.data );
			
            return false;
		},

		showItems: function () {

			return viewModel.get("items").view().length ? true : false;

		},

		showImagesList: function () {

			NM.util.openModal( $("#combination-images-list-modal") );

		},

		loadFinishes: function () {

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

	/*
	pub.currentItem = function() {

		var result = {
			forAttribute: viewModel.get("itemForAttributes"),
			forComponent: viewModel.get("itemFomComponents")
		}

		return result;

	},
	*/

	pub.init = function () {

		kendo.bind( fields.rootDetail, viewModel );

		viewModel.loadFinishes();

	};

	return pub;

}());