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

	var dataSource = NM.kendo.dataSource();

	var viewModel = kendo.observable({

		statusList: AP.page.attributeStatusList,

		callback: {
			onSave: undefined,
			onLoad: undefined
		},
		
		detailForm: {
			data: dataSource,
			action: "create",
			title: "Carica attributo",
		},

		valueForm: {
			data: {
				status: {
					id: "ACT"
				},
				id: "",
				name: ""
			},
			title: "Carica valore",
			labelButton: "Carica"
		},

		isValuesGridVisible: function() {

			var values = viewModel.get( "detailForm.data.values" );

			if ( values && values.length ) {
				return true;
			}

			return false;

		},

		isIdDisabled: function( event ) {

			return viewModel.get( "detailForm.action" ) == "update" ? true : false;

		},

		editValue: function( event ) {

			var labelButton = "Carica";
			var title = "Carica valore";
	
			if ( event?.data.id ) {
				labelButton = "Aggiorna";
				title = "Modifica valore < " + event.data.id + " >"
			}
	
			viewModel.set( "valueForm.data", event.data );
			viewModel.set( "valueForm.title", title );
			viewModel.set( "valueForm.labelButton", labelButton );

		},

		save: function() {

			var thisForm = AP.attribute.fields.detailForm;
			var status = thisForm.find(".status");

			status.html('<img src="/assets/main/img/ajax-loading.svg" width="20" height="20">');
			var attrId = viewModel.get( "detailForm.data.id" ) 

			if( thisForm.valid() ) {

				NM.util.ajax({ 
					method: "POST", 
					url: "/manager/ajax/attributes",
					data: JSON.stringify( viewModel.get( "detailForm" ) ),
					callback: {
						done: function( xhr ) {
							//status.html("<span class='green'>Attributo modificato</span> ");
							loadAttribute( { id: attrId } );

							if( viewModel.get("callback.onSave") ) {
								viewModel.get("callback.onSave")()
							}

						}
					}
				})

			}

			return false;

		},		

		saveValue: function() {

			var thisForm = AP.attribute.fields.valueForm;
			var status = thisForm.find(".status");

			console.log("status", status.length);

			status.html('<img src="/assets/main/img/ajax-loading.svg" width="20" height="20">');
			var attrId = viewModel.get( "detailForm.data.id" ) 

			if( thisForm.valid() ) {

				NM.util.ajax({ 
					method: "POST", 
					url: "/manager/ajax/attributes/values",
					data: JSON.stringify( { 
							value: viewModel.get( "valueForm.data" ), 
							attributeId: attrId
						} 
					),
					callback: {
						done: function( xhr ) {

							status.html("<span class='green'>Valore salvato</span> ");

							console.log("saveValue:done")

							//loadAttribute( { id: attrId } );
							
						}
					}
				})

			}

			return false;

		},

    });

	loadAttribute = function( { id, callback } ) {

		var action = "create";
		var labelButton = "Carica";
		var title = "Carica attributo";
		var thisUrl = "/manager/ajax/attributes/new";

		if ( id ) {
			action = "update";
			labelButton = "Aggiorna";
			title = "Modifica attributo < " + id +" >"		
			thisUrl = "/manager/ajax/attributes/" + id;
		}

		NM.util.ajax({ 
			method: "GET", 
			url: thisUrl,
			callback: {
				done: function( xhr ) {
					viewModel.set( "detailForm.data", xhr.data );
					viewModel.set( "detailForm.action", action );
					viewModel.set( "detailForm.title", title );
					viewModel.set( "detailForm.labelButton", labelButton );
					
					if ( callback?.hasOwnProperty("onLoad") ) {
						callback.onLoad()
					}

				}
			}
		})

	}

    pub.open = function( { id, callback } ) {

		console.log("id", id)
		console.log("callback", callback)

		viewModel.set("callback.onSave", callback?.onSave);
		viewModel.set("callback.onLoad", callback?.onLoad);

		loadAttribute( 
			{
				id: id, 
				callback: {
					onLoad: function() {
						NM.util.openModal( $("#attribute-detail-values-modal") );
					}
				}
			} 
		)

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

