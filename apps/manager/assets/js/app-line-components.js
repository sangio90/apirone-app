AP.lineComponents = AP.lineComponents || {};

AP.lineComponents.fields = {
    root: $("#line-components-root"),
}

$(document).ready(function(){

	if ( AP.lineComponents.fields.root.length ) {

		AP.lineComponents.detail.init();

	}

})

var showWorks = function() {

	$('#table-works').show()

	return false;

}


AP.lineComponents.detail = function() {

	var pub = {}

	var productId = "d4f0764f-fa4c-46bf-910a-06f3d0c3d626";

	var viewModel = kendo.observable({

		components: [],
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

		showVariants: function() {

			return !viewModel.get("showSearchPanel");
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

			$("#components-list-modal").modal("show");

            return false;
		},

        showConfig: function( event ) {

			var size = $(event.currentTarget).data('size');


			console.log("event", event)
			console.log("size", size)

			$("#comp-config_" + size ).show();

            return false;
		},

        openColors: function( event ) {

			console.log("openColors:event", event);

			viewModel.set( "currentVariant", event.data );

			viewModel.set("colors", event.data.colors);

            return false;
		},

        openVariants: function( event ) {

			console.log( "event", event );
			console.log( "event.data.id", event.data.id );

			//console.log( "event.parent", event.parent() );
			//console.log( "event.data.parent", event.data.parent().getByUid(  ) );

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

			return event.variants.length > 0;

		},

        showColorsResult: function( event ) {

			$("#components-colors-list-modal").modal("show");

            return false;
		},

	});   	

	pub.init = function() {

		console.log("comp:init")

		kendo.bind( AP.lineComponents.fields.root, viewModel )

	}	

	return pub;

}();