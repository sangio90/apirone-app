AP.lineAttributes = AP.lineAttributes || {};

AP.lineAttributes.fields = {
    root: $("#line-attributes-root"),
}

$(document).ready(function(){

	if ( AP.lineAttributes.fields.root.length ) {

		AP.lineAttributes.list.init();

	}

})


AP.lineAttributes.list = function() {

	var pub = {}
	
	var service = AP.attribute.detail;

	var viewModel = kendo.observable({

		attributesList: [],

		showAttributesList: function() {

			$("#line-attributes-list-modal").modal("show");

			this.searchAttributes()

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

		addAttribute: function( event ) {


			console.log("service", service);

			service.open();

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

		searchAttributes: function( event ) {

			//console.log("searchAttributes");

			var str = $('#attributes-search-input').val();
			var status = $('#attributes-list-search-form .status');

			status.html('Sto cercando...')

			$.ajax({
				method: "GET",
				url: "/manager/ajax/attributes",
				data: 'str=' + str,
				success: function(xhr) {
					viewModel.set( "attributesList", xhr.data );
					status.html( "Ho trovato " + xhr.count + " record.") 
				},
			});

            return false;

		},		

		showLinkedComponents: function( event ) {

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

        showLinkedComponents: function( event ) {

			$("#components-list-modal").modal("show");

            return false;
		},

        addValue: function( event ) {

			$("#value-add-modal").modal("show");

            return false;
		},

        addProperty: function( event ) {

			$("#property-add-modal").modal("show");

            return false;
		},

        showPropertiesList: function( event ) {

			console.log("showPropertiesList")

			$("#properties-list-modal").modal("show");

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

        showValues: function( event ) {

			$("#values-list-modal").modal("show");

			viewModel.set( "values", event.data.values );

            return false;
		},

        backToComponents: function( event ) {

			viewModel.set("showSearchPanel", true);

            return false;
		},

    });   	

	pub.init = function() {

		console.log("comp:init")

		kendo.bind( AP.lineAttributes.fields.root, viewModel )

	}	

	return pub;

}();