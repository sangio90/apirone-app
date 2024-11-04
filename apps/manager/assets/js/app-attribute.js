AP.attribute = AP.attribute || {};

AP.attribute.fields = {
    rootDetail: $("#attribute-detail-values-modal"),
    detailForm: $("#attribute-detail-form"),
    valueForm:  $("#attribute-values-add-form"),
    valuesForm: $("#attribute-values-form"),
}

$(document).ready(function(){

	if ( AP.attribute.fields.rootDetail.length ) {

		AP.attribute.detail.init();

	}

})

AP.attribute.detail = function() {

	var pub = {}

	var viewModel = kendo.observable({

		statusList: AP.page.attributeStatusList,
		
		detailForm: {
			data: {
				texts: [],
				values: []
			},
			title: "Carica attributo",
		},

		valueForm: {
			data: {
				status: {
					id: "ACT"
				},
				name: ""
			}
		},

		getTextName: function() {

			
			var texts = viewModel.get( "detailForm.data.texts" ).toJSON();
			
			if( texts.length ) {
				var text = AP.util.getMainText( texts );
				return text.name;
			}
	
			return '';

		},

        callback: {
            close: null
        },


		close: function() {

            callback.close()

		},

		saveValue: function() {

			var thisForm = AP.attribute.fields.valueForm;

			console.log("saveValue", thisForm);
			console.log("thisForm", thisForm.length);
			
			var status = thisForm.find(".status");

			status.html('<img src="/assets/main/img/ajax-loading.svg" width="20" height="20">');

			console.log("thisForm.valid", thisForm.valid());

			if( thisForm.valid() ) {

				NM.util.ajax({ 
					method: "POST", 
					url: "/manager/ajax/attributes/values",
					data: JSON.stringify( viewModel.get( "valueForm.data" ) ),
					callback: {
						done: function( xhr ) {

							status.html("");
							
						}
					}
				})

			}

			return false;

		},

    });

    pub.open = function( id ) {

		var action = "create";
		var thisUrl = "/manager/ajax/attributes/new";

		if ( id ) {
			action = "update";
			thisUrl = "/manager/ajax/attributes/" + id;
		}

		console.log( "open" );

		NM.util.ajax({ 
			method: "GET", 
			url: thisUrl,
			callback: {
				done: function( xhr ) {
					viewModel.set( "detailForm.data", xhr.data );
					viewModel.set( "detailForm.action", action );
					viewModel.set( "detailForm.title", "Modifica attributo " + xhr.data.id );
					
					NM.util.openModal( $("#attribute-detail-values-modal") );
				}
			}
		})

    };

    pub.save = function() {

    };

	pub.init = function() {

		console.log("AP.attribute.detail:init")

		kendo.bind( AP.attribute.fields.rootDetail, viewModel );

		var valueForm = AP.attribute.fields.valueForm;
		var detailForm = AP.attribute.fields.detailForm;

		detailForm.validate( {
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
				attr: {
					required: true
				}
			},
			messages: {
				attrId: {
					required: "ID richiesto",
					checkCode: "Solo numeri, lettere, trattino o trattino basso",
					remote: "L'attributo esiste"
				},
				attr: {
					required: "Descrizione principale richiesta",
				},
			},
		
		} );

		console.log("valueForm", valueForm);

		valueForm.validate( {
			onfocusout: function( element ) {
				$(element).valid();
			},
			rules: {
				newValueName: {
					required: true,
				},
				newValueStatus: {
					required: true
				}
			},
			messages: {
				newValueName: {
					required: "Valore richiesto",
				},
				newValueStatus: {
					required: "Stato richiesto",
				},
			},
		
		} );

	}	

	return pub;

}();

