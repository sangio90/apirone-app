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

	var getCurrentConfig = function() {

		var current = viewModel.get("currentItem");
		var baseUrl = "/manager/ajax/components";

		console.log("current", current);

		var result = {
			modalTitle: "",
			modifyUrl: "",
			readUrl: ""
		};

		if( current ) {

			switch( current.type ) {
			
				case "lineSize":

					result.modalTitle = "linea a dimensione: " + current.line.name + " / " + current.size.name;
					result.readUrl = baseUrl + "?by=linesize&lineId=" + current.line.id + "&sizeId=" + current.size.id;
					result.modifyUrl = result.readUrl
				  
					break;
				
				case "item":

					result.modalTitle = "elemento: " + current.attribute.name + " / " + current.attributeValue.name;
					result.readUrl = baseUrl + "?by=item&&itemId=" + current.item.id;
					result.modifyUrl = result.readUrl;
					
					break;
				
				case "combination":

					result.modalTitle = "combinazione: " + current.combination.name;
					result.readUrl = baseUrl + "?by=combination&combinationId=" + current.combination.id;
					result.modifyUrl = result.readUrl;
					
					break;
				
				default:
			}

		}

		console.log("getCurrentConfig:result", result)

		return result;

	}

	var createId = function( row ) {

		console.log("createId:row", row);

		var id = row.product.id + "$$$" + row.color.id + "$$$" + row.variant.id;

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
                filters.push( { field: "product.name", operator: "contains", value: str } );
            };

            if ( typeId.length ) {
                filters.push( { field: "product.processingType.id", operator: "eq", value: typeId } );
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

			console.log( "addColor:product", product );
			console.log( "addColor:variant", variant );

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

			console.log( "addColor:exists", exists );

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
				url: "/manager/ajax/products", 
				params: params, 
				requestEnd: requestEnd, 
				requestStart: requestStart
			});

			viewModel.set( "components", dataSource );
			
            return false;

		},

		save: function (event) {

			var thisForm = $("#component-list-selected-form");
			var status = $("#status-selected");

            //var params = thisForm.serializeJSON();

			var current = viewModel.get("currentItem");

			NM.util.ajax({
				method: "POST",
				url: getCurrentConfig().modifyUrl,
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

        getModalTitle: function ( event ) {

			var name = getCurrentConfig().modalTitle;

			return name;

		},

	});

	pub.open = function ( item ) {

		//console.log("open:itemId", itemId);

		viewModel.set( "currentItem", item );

		//console.log( "readUrl", getCurrentConfig().readUrl );

		NM.util.ajax({
			method: "GET",
			url: getCurrentConfig().readUrl,
			callback: {
				done: function (xhr) {

					viewModel.get("selected").data( xhr.data );

					NM.util.openModal( $("#component-list-modal") );

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