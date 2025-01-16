AP.component = AP.component || {};

AP.component.fields = {
    rootList: $("#component-list-modal"),
};

$(document).ready(function (){

	if (AP.component.fields.rootList.length) {

		AP.component.list.init();

	}

});


AP.component.list = (function () {

	var pub = {};
	var fields = AP.component.fields;

	var dataSources = {
		selected: new kendo.data.DataSource({ data: [] })
	};

	var selectedExists = function( row ) {

		var id = createId( row );

		console.log("selectedExists:id", id);

		var dataSource = viewModel.get("selected");

		for( var item of dataSource.data() ) {
			if ( item.id == id ) {
				return true;
			}
		}

		return false;

	}

	var createId = function( row ) {

		console.log("createId:row", row);

		var id = row.comp.id + "$$$" + row.color.id + "$$$" + row.variant.id;

		console.log("createId:id", id);

		return id;

	}

	var viewModel = kendo.observable({

		components: undefined,
		variants: [],
		selected: dataSources.selected,

		colors: [],
		showColors: false,
		showSearchPanel: true,
		variantsTitle: "Varianti",
		currentVariant: {},
		currentProduct: {},

		currentItem: undefined,

		showSearchResult: function () {

			return viewModel.get("components")?.total() > 0;
		
		},

		resetFilterSelected: function () {

			var dataSource = viewModel.get("selected");

            var thisForm = $("#component-list-selected-form");

            thisForm.find( "input[name=str]" ).val("");

            dataSource.filter( [] );

            dataSource.view();

            return false;
		},

		filterSelected: function () {

            var thisForm = $("#component-list-selected-form");
			var dataSource = viewModel.get("selected");
			
            var str = thisForm.find( "input[name=str]" ).val();
            var typeId = thisForm.find( "select[name=processingTypeId]" ).val();

            var filters = [];

            if ( str.length ) {
                filters.push( { field: "comp.name", operator: "contains", value: str } );
            };

            if ( typeId.length ) {
                filters.push( { field: "comp.processingType.id", operator: "eq", value: typeId } );
            };

            dataSource.filter( filters );

            dataSource.view();

            return false;
		},

		showVariants: function () {

			console.log("showVariants");

			//viewModel.set("variants", []);
			//viewModel.set("colors", []);

			return !viewModel.get("showSearchPanel");
		},

		addColor: function (event) {

			var color = event.data;

			var product = viewModel.get("currentProduct");
			var variant = viewModel.get("currentVariant");

			console.log( "addColor:comp", comp );

			var row = {
				//id: createId( comp ),
				quantity: 1,
				product: {
					id: product.id,
					name: product.name,
					processingType: {
						id: product.processingType.id,
						name: product.processingType.name
					}
				},
				color: {
					id: color.id,
					name: color.name
				},
				variant: {
					id: variant.id,
					name: variant.name
				}
			};

			row.id = createId( row );

			var exists = selectedExists( row );

			console.log("addColor:exists", exists);

			if( exists ) {
				AP.widget.autoClearMessage( "status-selected", "<span class='red'>È stato già aggiunto</span>" );
			} else {
				viewModel.get("selected").add( row );
			}

			return false;
		},

		search: function (event) {

			var thisForm = $("#component-list-search-form");
			var status = thisForm.find(".status");

			var requestStart = function() {
				status.html("Sto cercando...");
			};

			var requestEnd = function( xhr ) {
				status.html("Ho trovato " + xhr.response.total + " componenti");
			};

            var params = thisForm.serializeJSON();
			
			var dataSource = NM.kendo.dataSource({ 
				url: "/manager/ajax/components", 
				params: params, 
				requestEnd: requestEnd, 
				requestStart: requestStart
			});

			viewModel.set("components", dataSource );
			
            return false;

		},

		save: function (event) {

			var thisForm = $("#component-list-selected-form");
			var status = $("#status-selected");

            //var params = thisForm.serializeJSON();

			var current = viewModel.get("currentItem");

			NM.util.ajax({
				method: "POST",
				url: "/manager/ajax/combination-items/" + current.id + "/components",
				data: JSON.stringify( viewModel.get("selected").data() ),
				callback: {
					done: function (xhr) {

						if(xhr.status == "SUCCESS") {

							console.log("save:SUCCESS")

							//viewModel.set("components", xhr.data);
							AP.widget.autoClearMessage( "status-selected", "<span class='green'>Configurazione salvata</span>" );
						}

					}
				}
			});

            return false;

		},

        openColors: function (event) {

			console.log("openColors:event", event);

			viewModel.set("currentVariant", event.data);

			viewModel.set("colors", event.data.colors);

            return false;
		},

        openVariants: function (event) {

			viewModel.set("currentProduct", event.data);

			viewModel.set("showSearchPanel", false);
			viewModel.set("variantsTitle", "Varianti per " + event.data.name + " <small>(" + event.data.id + ")</small>");
			viewModel.set("variants", event.data.variants);

            return false;
		},

        backToComponents: function (event) {

			viewModel.set("showSearchPanel", true);

            return false;
		},

        showVariantsForCount: function (event) {

			return event.variants.length > 0;

		},

        showColorsResult: function (event) {

			$("#components-colors-list-modal").modal("show");

            return false;
		},

		showSelectedTable: function () {

			var dataSource = viewModel.get("selected");

			return dataSource.total() > 0;
		
		},

		removeComponent: function (event) {

			var dataSource = viewModel.get("selected");

			console.log("removeComponent:event", event);
			console.log("removeComponent:event.data.uid", event.data.uid);

			var row = dataSource.getByUid( event.data.uid );

			dataSource.remove( row );

			return false;

		},

        getCurrentItemName: function (event) {

			var attrName = viewModel.get("currentItem.attribute.name")
					+ " / "
					+ viewModel.get("currentItem.attributeValue.name");

            return attrName;
		},

	});

	pub.setCurrentItem = function (item) {

		viewModel.set("currentItem", item);

	};

	pub.open = function (itemId) {

		console.log("open:itemId", itemId);

		NM.util.ajax({
			method: "GET",
			url: "/manager/ajax/combination-items/" + itemId + "/components",
			callback: {
				done: function (xhr) {

					viewModel.get("selected").data( xhr.data );

					NM.util.openModal($("#component-list-modal"));

				}
			}
		});

	};

	pub.init = function () {

		console.log("component:init");

		kendo.bind(fields.rootList, viewModel);

	};

	return pub;

}());