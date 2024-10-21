AP.attribute = AP.attribute || {};

AP.attribute.fields = {
    rootDetail: $("#attribute-detail-modal"),
    detailForm: $("#attribute-detail-form"),
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
		detailForm: {

		},

        callback: {
            close: null
        },

		/*
		open: function() {

			$("#attribute-detail-modal").modal("show");

		},
		*/

		close: function() {

            callback.close()

		},


		save: function() {

			var thisForm = AP.attribute.fields.detailForm;
			var status = thisForm.find(".status");

			if( thisForm.valid() ) {

				NM.util.ajax({ 
					method: "POST", 
					url: "/manager/ajax/attributes",
					data: JSON.stringify( viewModel.get( "detailForm" ) ),
					callback: {
						done: function( xhr ) {

							status.html('<img src="/assets/main/img/ajax-loading.svg" width="20" height="20">');

							console.log("xhr", xhr)
						}
					}
				})

			}

			return false;

		},

    });

    pub.open = function( id ) {

		if ( id ) {
			var thisUrl = "/manager/ajax/attributes/" + id;
		} else {
			var thisUrl = "/manager/ajax/attributes/new";
		}

		NM.util.ajax({ 
			method: "GET", 
			url: thisUrl,
			callback: {
				done: function( xhr ) {
					viewModel.set( "detailForm", xhr.data );
					NM.util.openModal( $("#attribute-detail-modal") );
				}
			}
		})

    };

    pub.save = function() {

    };

	pub.init = function() {

		console.log("AP.attribute.detail:init")

		var thisForm = AP.attribute.fields.detailForm;

		kendo.bind( AP.attribute.fields.rootDetail, viewModel )

		thisForm.validate( {
			onfocusout: function( element ) {
				$(element).valid();
			},
			rules: {
				attrId: {
					required: true,
					checkCode: true,
					remote: {
						url: "/manager/ajax/attributes/exists",
						dataFilter: function( xhr ) {
							var json = JSON.parse( xhr );
							return json.data == false;
						}
					}
				},
			},
			messages: {
				attrId: {
					required: "ID richiesto",
					checkCode: "Solo numeri, lettere, trattino o trattino basso",
					remote: "L'attributo esiste"
				},
			},
		
		} );

	}	

	return pub;

}();

