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
		langs: AP.config.langs,
		detailForm: {
			
		},

        callback: {
            close: null
        },

		open: function() {

			//NM.util.modal( { id: $("#attribute-detail-modal") } )

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

    pub.open = function( id ) {

		if ( id ) {
			var thisUrl = '/ajax/attributes/' + id
		} else {
			var thisUrl = '/ajax/attributes/new'
		}

		/*
		NM.util.ajax({ method: 'GET', url: thisUrl,
			callback: {
				done: function() {
					console.log("done")
				}
			}
		})
		*/

		NM.util.openModal( $("#attribute-detail-modal") );

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
					remote: {
						url: "/ajax/attributes/" + $('#attrId').val() + "/exists",
						type: "GET",
						data: {
							username: function() {
								return $( "#username" ).val();
						  	}
						}
					}
				},
			},
			messages: {
				attrId: {
					required: "ID richiesto"
				},
			},
		
		} );

		thisForm.find("input.lang").each(function(){

			console.log("this", $(this))
			
			$(this).rules("add", { 
				required: true,
				messages: { required: "Descrizione richiesto" }
			});
	   	
		});

	}	

	return pub;

}();

