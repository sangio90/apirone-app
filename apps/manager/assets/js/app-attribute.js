AP.attribute = AP.attribute || {};

AP.attribute.fields = {
    rootDetail: $("#attribute-detail-modal"),
}

$(document).ready(function(){

	if ( AP.attribute.fields.rootDetail.length ) {

		AP.attribute.detail.init();

	}

})

AP.attribute.detail = function() {

	var pub = {}

	var viewModel = kendo.observable({

        title: "Carica attributo",

		data: {
			texts: AP.config.langs
		},

        callback: {
            close: null
        },

		open: function() {

			NM.util.modal( { id: $("#attribute-detail-modal") } )

			$("#attribute-detail-modal").modal("show");

		},

		close: function() {

            callback.close()

		},


		save: function() {

			$.ajax({
				method: "GET",
				url: "/manager/ajax/attributes",
				data: 'str=' + str,
				success: function(xhr) {
					viewModel.set( "attributesList", xhr.data );
					status.html( "Ho trovato " + xhr.count + " record.") 
				},
			});

		},

    });

    pub.open = function() {

		NM.util.openModal( $("#attribute-detail-modal") );

    };

    pub.save = function() {

    };

	pub.init = function() {

		console.log("AP.attribute.detail:init")

		kendo.bind( AP.attribute.fields.rootDetail, viewModel )

		//NM.kendo.loadTemplate()

	}	

	return pub;

}();

