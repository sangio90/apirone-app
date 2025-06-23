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
		selected: new kendo.data.DataSource(
			{
				data: [],
				// calculates an id every time the ds is modified
				change: function( event ) {
					var data = this.data();

					for( var item of data ) {
						item.code = createCode( item );
					}

				}
			}
		)
	};

	var selectedExists = function( row ) {

		var code = createCode( row );

		var dataSource = viewModel.get("selected");

		for( var item of dataSource.data() ) {
			if ( item.code == code ) {
				return true;
			}
		}

		return false;

	};

	var getCurrentConfig = function() {

		var current = viewModel.get("currentItem");
		var baseUrl = "/manager/ajax/components";

		var result = {
			modalTitle: "",
			modifyUrl: "",
			readUrl: ""
		};

		if( current ) {

			switch( current.type ) {

				case "lineSize":

					result.modalTitle = "Componenti per linea a dimensione: " + current.line.name + " / " + current.size.name;
					result.readUrl = baseUrl + "?by=linesize&lineId=" + current.line.id + "&sizeId=" + current.size.id;
					result.modifyUrl = result.readUrl;

					break;

				case "fruit":

					result.modalTitle = "Componenti base per frutto: " + current.fruit.code;
					result.readUrl = baseUrl + "?by=fruit&fruitId=" + current.fruit.id;
					result.modifyUrl = result.readUrl;

					break;

				case "fruitItem":

					result.modalTitle =	"Componenti per elemento: " + current.attribute.name + " / " + current.attributeValue.name;
					result.readUrl = baseUrl + "?by=fruitItem&&itemId=" + current.item.id;
					result.modifyUrl = result.readUrl;

					break;

				case "item":

					result.modalTitle = "Componenti per elemento: " + current.attribute.name + " / " + current.attributeValue.name;
					result.readUrl = baseUrl + "?by=item&&itemId=" + current.item.id;
					result.modifyUrl = result.readUrl;

					break;

				case "combination":

					result.modalTitle = "Componenti base per combinazione: " + current.combination.name;
					result.readUrl = baseUrl + "?by=combination&combinationId=" + current.combination.id;
					result.modifyUrl = result.readUrl;

					break;

				case "attributeValue":

					result.modalTitle = "Componenti base per il valore: " + current.attribute.name + " / " + current.rawValue.name;
					result.readUrl = baseUrl + "?by=attributeValue&attributeValueId=" + current.attributeValue.id;
					result.modifyUrl = result.readUrl;

					break;

				default:
			}

		}

		return result;

	};

	var createCode = function( row ) {

		var code = row.rawProduct.id + "$$$" + row.color.id + "$$$" + row.variant.id;

		return code;

	};

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

            var filter = {
				logic: "or",
				filters: []
			};

            if ( str.length ) {
                filter.filters.push( { field: "rawProduct.id", operator: "contains", value: str } );
                filter.filters.push( { field: "rawProduct.name", operator: "contains", value: str } );
            };

            if ( typeId.length ) {
                filter.filters.push( { field: "rawProduct.processingType.id", operator: "eq", value: typeId } );
            };

            dataSource.filter( filter );

            dataSource.view();

            return false;
		},

		showVariants: function () {

			return !viewModel.get("showSearchPanel");
		},



		addColor: function (event) {

			var color = event.data;

			var product = viewModel.get("currentProduct");
			var variant = viewModel.get("currentVariant");

			var row = {
				id: "",
				quantity: 1,
				rawProduct: {
					id: product.id,
					name: product.name,
					processingType: {
						id: product.processingType.id,
						name: product.processingType.name
					},
					measurementUnit: {
						id: product.measurementUnit.id,
						name: product.measurementUnit.name
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

			row.code = createCode( row );

			var exists = selectedExists( row );

			if( exists ) {
				AP.widget.autoClearMessage( "status-selected", "<span class='auto-clear-status error'>È stato già aggiunto</span>" );
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
				url: "/manager/ajax/raw-products",
				params: params,
				requestEnd: requestEnd, 
				requestStart: requestStart
			});

			viewModel.set( "components", dataSource );

            return false;

		},

		save: function (event) {

			NM.util.ajax({
				method: "POST",
				url: getCurrentConfig().modifyUrl,
				data: JSON.stringify( viewModel.get("selected").data() ),
				callback: {
					done: function (xhr) {

						if(xhr.status == "SUCCESS") {
							
							AP.widget.notify("success", "Configurazione salvata");
							refreshSelectedComponents();

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

			viewModel.set("colors", []);

            return false;
		},

        showComponentsList: function (event) {

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

		remove: function (event) {

			var dataSource = viewModel.get("selected");

			var row = dataSource.getByUid( event.data.uid );

			dataSource.remove( row );

			return false;

		},

        getModalTitle: function ( event ) {

			var name = getCurrentConfig().modalTitle;

			return name;

		},

	});

	var refreshSelectedComponents = function( onDone ) {

		console.log("refreshSelectedComponents:onDone", onDone);

		NM.util.ajax({
			method: "GET",
			url: getCurrentConfig().readUrl,
			callback: {
				done: function (xhr) {

					viewModel.get("selected").data( xhr.data );

					if( onDone ) {
						onDone()
					}

				}
			}
		});

	}

	pub.open = function ( item ) {

		viewModel.set( "currentItem", item );

		viewModel.set( "colors", [] );
		viewModel.set( "variants", [] );

		viewModel.showComponentsList();

		var onDone = function() {
			NM.util.openModal( $("#component-list-modal") );
			console.log("done")
		}

		refreshSelectedComponents( onDone=onDone )

	};

	pub.init = function () {

		kendo.bind(fields.rootList, viewModel);

	};

	return pub;

}());