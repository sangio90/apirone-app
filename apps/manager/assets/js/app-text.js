AP.text = AP.text || {};

AP.text.fields = {
    listRoot: $('#line-list-root'),
    detailRoot: $('#line-detail-form')
}

$(document).ready(function(){

	if ( AP.text.fields.listRoot.length ) {

	    AP.text.list.init();

	}

	if ( AP.text.fields.detailRoot.length ) {

	    AP.text.detail.init();

	}

})

AP.text.list = function() {

	var pub = {}

	var dataSources = {
		items: NM.kendo.dataSource( { url: "/manager/ajax/texts" } )
	}

	var viewModel = kendo.observable({
		rows: dataSources.items,
        
        //TODO: to remove
        open: function( event ) {

            var id = event.data.id
            window.open( "/manager/lines/" + id, '_blank').focus();

        },

        configure: function( event ) {
            var id = event.data.id
            window.open( "/manager/lines/" + id + "/attributes", '_blank').focus();

        },

		print: function( item ) {

            window.open('/manager/lines/print', '_blank');

            return false;
		},


	});

	pub.init = function() {

        console.log("init")

        kendo.bind( AP.text.fields.listRoot, viewModel );

	}	

    return pub;
}();
