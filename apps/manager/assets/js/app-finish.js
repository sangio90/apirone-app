AP.finish = AP.finish || {};

AP.finish.fields = {
    listRoot: $('#finish-list-root'),
    searchListForm: $('#finish-grid-search-form'),
    combinationsRoot: $('#finish-combinations-root')
}

$(document).ready(function(){

	if ( AP.finish.fields.listRoot.length ) {

	    AP.finish.list.init();

	}

})

AP.finish.list = function() {

	var pub = {}

	var dataSources = {
		items: NM.kendo.dataSource( { url: "/manager/ajax/finishes" } )
	}

	var viewModel = kendo.observable({
		rows: dataSources.items,
        
        search: function( event ) {

            var thisForm = AP.finish.fields.searchListForm;

            var params = thisForm.serializeJSON();

            console.log( "search", event );
            console.log( "params", params );

            //$('form').serializeJSON();

            viewModel.rows.read( params )

            return false;

        },

        open: function( event ) {

            var id = event.data.id
            window.open( "/manager/finishes/" + id, '_blank').focus();

        },

	});

	pub.init = function() {

        console.log("AP.finish:init")

        kendo.bind( AP.finish.fields.listRoot, viewModel );

	}	

    return pub;
}();

