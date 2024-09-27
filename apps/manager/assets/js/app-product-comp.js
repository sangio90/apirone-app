AP.component = AP.component || {};

AP.component.fields = {
    rootDetail: $("#product-components-root"),
}

$(document).ready(function(){

	if ( AP.component.fields.rootDetail.length ) {

		AP.component.detail.init();

	}

})


AP.component.detail = function() {

	var pub = {}

	var productId = "d4f0764f-fa4c-46bf-910a-06f3d0c3d626";

	var viewModel = kendo.observable({

		components: [],
		attributes: [],
		currentAttribute: null,
		componentsForProduct: [],
		values: [],
		variants: [],
		selected: [],
		colors: [],
		showColors: false,
		showSearchPanel: true,
		variantsTitle: "Varianti",
		currentVariant: {},
		currentComponent: {},

		showSearchResult: function() {

			console.log("components > 0", viewModel.get( "components" ).length > 0);
			console.log("showVariants", viewModel.get( "showVariants" ));
			
			//var ret = viewModel.get( "components" ).length > 0 && !viewModel.get( "showVariants" );
			var ret = viewModel.get( "components" ).length > 0;
			return ret;
		},

		addComponent: function( event ) {

			var cur = viewModel.get("currentAttribute");

			console.log("event", event )

			var count = $('#product_counter_' +  cur ).html();

			console.log("count", count )

			var tot = parseInt(count) + 1;

			console.log("tot", tot)

			$('#product_counter_' +  cur ).html( tot )


			return false;
		},

		addDataFromErp: function( event ) {

			viewModel.set( "values", event.data.values );

			$("#components-values-list-modal").modal("show");
			
			return false;
		},

		showValues: function( event ) {

			viewModel.set( "values", event.data.values );

			$("#components-values-list-modal").modal("show");
			
			return false;
		},

		addAttribute: function( event ) {

			console.log("event", event);

			var prds = viewModel.get( "componentsForProduct" );

			prds.push( event.data );

			viewModel.set( "componentsForProduct", prds );

			return false;
		},

		addSubAttribute: function( event ) {

			console.log("event", event);

			return false;
		},

		useComponent: function( event ) {

			var comps = viewModel.get("selected");

			comps.push( event.data );

			viewModel.set("selected", comps);
			
			return false;
		},

		useColor: function( event ) {

			var color = event.data;

			var comp = viewModel.get("currentComponent");
			var variant = viewModel.get("currentVariant");

			var row = {
				comp: {
					id: comp.id,
					name: comp.name
				},
				color: {
					id: color.id,
					name: color.name
				},
				variant: {
					id: variant.id,
					name: variant.name
				}
			}


			console.log("event:useColor", event );

			var comps = viewModel.get("selected");

			comps.push( row );

			viewModel.set("selected", comps);
			
			return false;
		},

		searchComponents: function( event ) {

			console.log("searchComponents");

			var str = $('#components-search-input').val();
			var status = $('#components-list-search-form .status');

			status.html('Sto cercando...')

			$.ajax({
				method: "GET",
				url: "/manager/ajax/components",
				data: 'str=' + str,
				success: function(xhr) {
					viewModel.set( "components", xhr.data );
					status.html( "Ho trovato " + xhr.count + " record.") 
				},
			});

            return false;

		},		

        showComponentsList: function( event ) {

			console.log("showComponentsList", event)

			viewModel.set( "currentAttribute", event.data.id );


			console.log("showComponentsList")

			$("#components-list-modal").modal("show");

            return false;
		},

        showPropertiesList: function( event ) {

			console.log("showComponentsList", event)

			viewModel.set( "currentProperty", event.data.id );

			console.log("showComponentsList")

			$("#properties-list-modal").modal("show");

            return false;
		},

        showAttributesList: function( event ) {

			$("#attributes-list-modal").modal("show");

            return false;
		},

        openColors: function( event ) {

			console.log("openColors:event", event);

			viewModel.set( "currentVariant", event.data );

			viewModel.set("colors", event.data.colors);

            return false;
		},

        openVariants: function( event ) {

			console.log("event.data", event.data);

			console.log( "event", event );
			console.log( "event.data.id", event.data.id );

			viewModel.set( "currentComponent", event.data );

			viewModel.set( "showSearchPanel", false );
			viewModel.set( "variantsTitle", "Varianti per " + event.data.name + " <small>(" + event.data.id + ")</small>" );
			viewModel.set( "variants", event.data.variants );

            return false;
		},

        backToComponents: function( event ) {

			viewModel.set("showSearchPanel", true);

            return false;
		},

        showVariantsForCount: function( event ) {

			console.log("event.variants.length", event.variants.length);

			return event.variants.length > 0;

		},

        showColorsResult: function( event ) {

			$("#components-colors-list-modal").modal("show");

            return false;
		},

	});   	

	pub.init = function() {

		console.log("comp:init")

		kendo.bind( AP.component.fields.rootDetail, viewModel );

		viewModel.set( "attributes", attributes );

	}	

	return pub;

}();