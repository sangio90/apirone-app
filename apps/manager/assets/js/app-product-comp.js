AP.component = AP.component || {};

AP.component.fields = {
    rootDetail: $("#product-components-root"),
}

$(document).ready(function(){

	if ( AP.component.fields.rootDetail.length ) {

		AP.component.detail.init();

	}

})


var addComponents = function() {

    $("#list-compoments-modal").modal("show");

}

var showColors = function() {

	$(".general-variant").hide();
    $("#table-variant-colors").show();

}

var showVariants = function() {

	$(".general-variant").hide();
    $("#table-variant-variants").show();

}

AP.component.detail = function() {

	var pub = {}

	var productId = "d4f0764f-fa4c-46bf-910a-06f3d0c3d626";

	var viewModel = kendo.observable({

		components: [],
		colors: [],
		variants: [],
		selected: [],

		showSearchResult: function() {
			var ret = viewModel.get( "components" ).length > 0;

			console.log("showSearchResult", viewModel.get( "components" ).length)

			return ret;
		},

		useComponent: function( event ) {

			var comps = viewModel.get("selected");

			comps.push( event.data );

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

			/*
			AP.util.ajax( {
				method: "POST",
				url: "/manager/ajax/components",
				//data: selected.serialize(),
				callback: {
					done: function() {
						NM.widget.notify( "success", "Dati cancellati con successo" );
						//dataSources.items.read();
					}
				}
			} )
			*/

            return false;
		},

        showColors: function( event ) {

			console.log("event", event);

			viewModel.set("colors", event.data.colors);

			$("#components-colors-list-modal").modal("show");

            return false;
		},

        showColorsForCount: function( event ) {

			return event.colors.length > 0;

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

		kendo.bind( AP.component.fields.rootDetail, viewModel )

	}	

	return pub;

}();