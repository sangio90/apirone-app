AP.component = AP.component || {};

AP.component.fields = {
    rootDetail: $('#product-component-root'),
}

$(document).ready(function(){

	if ( AP.component.fields.rootDetail.length ) {

		//AP.role.list.init();

	}

})


/*
var addComponents = function() {

    $('#list-compoments-modal').modal('show');

}

var addProducts = function() {

    $('#list-products-modal').modal('show');

}
	*/

AP.component = function() {

	var pub = {}


	var viewModel = kendo.observable({

		components: undefined,

        listCompotents: function( event ) {

			$('#list-compoments-modal').modal('show');

			FW.utils.ajax( {
				method: "POST",
				url: "/manager/ajax/option/remove-all",
				data: selected.serialize(),
				callback: {
					done: function() {
						FW.widget.notify( "success", "Dati cancellati con successo" );
						dataSources.items.read();
					}
				}
			} )

            return false;
		},

	});   	

	pub.init = function() {

		console.log("comp:init")

		kendo.bind( AP.component.fields.rootDetail, viewModel )

	}	

	return pub;

}();