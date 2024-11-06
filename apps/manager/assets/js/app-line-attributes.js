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
		configList: [],

		selectAttribute: function( event ) {

			console.log( event );

			var sizeId = $("#line-config-row").find("[name=sizeId]").val();
			var finishId = $("#line-config-row").find("[name=finishId]").val();

			$.ajax({
				method: "POST",
				url: "/manager/ajax/lines/" + AP.page.lineId + "/add",
				data: { 
					finishId: finishId , 
					sizeId: sizeId, 
					lineId: AP.page.lineId, 
					attributeId: event.data.id 
				},
				success: function(xhr) {

					viewModel.getConfiguration()

				},
			});

		},

		getConfiguration: function( event ) {

			var sizeId = $("#line-config-row").find("[name=sizeId]").val();
			var finishId = $("#line-config-row").find("[name=finishId]").val();

			$.ajax({
				method: "GET",
				url: "/manager/ajax/lines/" + AP.page.lineId + "/size/" + sizeId + "/finish/" + finishId + "/conf",
				success: function(xhr) {
					viewModel.set( "configList", xhr.data )
				},
			});

		},

		getAttributeName: function( event ) {

			var text = AP.util.getMainText( event.texts )

			return text.name;

		},

		addAttribute: function( event ) {

			service.open( { id: '' } );

			return false;
		},

		showAttributesList: function() {

			$("#line-attributes-list-modal").modal("show");

			this.searchAttributes()

		},

		showAttributeValues: function( event ) {

			console.log("event.data.id", event.data.id)

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

		viewModel.getConfiguration();	

	}	

	return pub;

}();