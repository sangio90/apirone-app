AP.text = AP.text || {};

AP.text.fields = {
    listRoot   : $('#text-list-root'),
    listSearch : $('#text-search-form'),
    detailModal: $('#text-detail-modal')
}

$(document).ready(function(){

	if ( AP.text.fields.listRoot.length ) {

	    AP.text.list.init();

	}

})

AP.text.list = function() {

	var pub = {}

	var viewModel = kendo.observable({
		
        rows: undefined,
		
        detailForm: {
            data: {
                texts: undefined
            },
            title: "Traduzione",
            labelButton: "Salva"
        },
        
        edit: function( event ) {

            NM.util.ajax({ 
                method: "GET", 
                url: "/manager/ajax/texts/" + event.data.id + "/all",
                callback: {
                    done: function( xhr ) {

                        viewModel.set( "detailForm.data.texts", xhr.data );
                        NM.util.openModal( AP.text.fields.detailModal );

                    }
                }
            })


        },

		print: function( item ) {

            window.open('/manager/lines/print', '_blank');

            return false;
		},

        search: function() {

            var qs = AP.text.fields.listSearch.serialize();

            var dataSource = NM.kendo.dataSource({ url: "/manager/ajax/texts?" + qs })

            viewModel.set( "rows", dataSource );
    
        }


	});


	pub.init = function() {

        kendo.bind( AP.text.fields.listRoot, viewModel );

        viewModel.search();

	}	

    return pub;
}();
