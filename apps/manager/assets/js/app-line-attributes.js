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

		getAttributeName: function( event ) {

			var text = AP.util.getMainText( event.texts )

			return text.name;

		},

		addAttribute: function( event ) {

			service.open();

			return false;
		},

		showAttributesList: function() {

			$("#line-attributes-list-modal").modal("show");

			this.searchAttributes()

		},

		showAttributeValues: function( event ) {

			//console.log("event.data.id", event.data.id)

			service.open( 
				{ 
					id: event.data.id, 
					callback: { 
						onSave: function() {
							viewModel.searchAttributes();
						},
					} 
				}
			)

			return false;

		},

		searchAttributes: function( event ) {

			console.log("searchAttributes");

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

    });   	

	pub.init = function() {

		console.log("comp:init")

		kendo.bind( AP.lineAttributes.fields.root, viewModel )

	}	

	return pub;

}();