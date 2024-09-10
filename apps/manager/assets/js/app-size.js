AP.size = AP.size || {};

AP.size.fields = {
    listRoot: $('#size-list-root'),
    detailRoot: $('#size-detail-form')
}

$(document).ready(function(){

	if ( AP.size.fields.listRoot.length ) {

	    AP.size.list.init();

	}

})

AP.size.list = function() {

	var pub = {}

	var dataSources = {
		items: NM.kendo.dataSource( { url: "/manager/ajax/sizes" } )
	}

	var viewModel = kendo.observable({
		rows: dataSources.items,
        
        open: function( event ) {

            var id = event.data.id
            window.open( "/manager/sizes/" + id, '_blank').focus();

        },

		print: function( item ) {

            window.open('/manager/sizes/print', '_blank');

            return false;
		},


	});

	pub.init = function() {

        console.log("size:init")

        kendo.bind( AP.size.fields.listRoot, viewModel );

	}	

    return pub;
}();

