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

	var defaults = {

		detailForm: {
			data: {
				status: {
					id: "ACT"
				},
				id: "",
				orderBy: 0,
				selectedCategories: [],
				mainText: {
					id: "",
					name: "",
					lang: {
						id: "IT"
					}
				}
			},
			title: "Carica attributo",
			action: "create"
		},

		valueForm: {
			data: {
				status: {
					id: "ACT"
				},
				id: "",
				orderBy: 0,
				mainText: {
					id: "",
					name: "",
					lang: {
						id: "IT"
					}
				}
			},
			title: "Carica valore",
			labelButton: "Carica"
		},
	
	}
	//var dataSource = NM.kendo.dataSource();

	var viewModel = kendo.observable({

		detailForm: defaults.detailForm,
		valueForm: defaults.valueForm,

		categories: AP.page.categories,		
		statusList: AP.page.attributeStatusList,

		callback: {
			onSave: undefined,
			onLoad: undefined
		},

		resetDetailForm: function() {

			viewModel.set("detailForm", defaults.detailForm );

		},
		
		resetValueForm: function() {

			viewModel.set("valueForm", defaults.valueForm );

		},
		
		
		isValuesGridVisible: function() {

			var values = viewModel.get("detailForm.data.values");

			if ( values?.total() ) {
				return true;
			}
			
			return false;

		},

		isIdDisabled: function( event ) {

			var action = viewModel.get( "detailForm.action" );

			console.log("isIdDisabled:action", action);

			return  action == "update" ? true : false;

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
	
		edit: function( event ) {

			var selectedCategories = [];

			for (var category of event.data.categories)  {
				selectedCategories.push(category.id);
			}

			viewModel.set( "detailForm.data", event.data );

			viewModel.set( "detailForm.data.selectedCategories", selectedCategories );
			viewModel.set( "detailForm.title", "Modifica attributo < " + event.data.id + " >" );

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

							setTimeout(	function() {
								viewModel.resetValueForm()
							}, 1000 )

						}
					}
				})

			}

			return false;

		},		

		saveValue: function() {

			var thisForm = AP.attribute.fields.valueForm;
			var status = $("#attribute-values-add-form-status");

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
							loadAttribute( { id: attrId } );
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

		if ( id.length ) {
			action = "update";
			labelButton = "Aggiorna";
			title = "Modifica attributo < " + id +" >"
			thisUrl = "/manager/ajax/attributes/" + id;
		}

		console.log("id", id);

		NM.util.ajax({ 
			method: "GET", 
			url: thisUrl,
			cache: false,
			callback: {
				done: function( xhr ) {

					var valuesDataSource = new kendo.data.DataSource({
						data: xhr.data.values,
						sort: { field: "orderBy", dir: "asc" } 
					});

					delete xhr.data.values;

					viewModel.set( "detailForm.data", xhr.data );
					viewModel.set( "detailForm.data.values", valuesDataSource );
					viewModel.set( "detailForm.action", action );
					viewModel.set( "detailForm.title", title );
					viewModel.set( "detailForm.labelButton", labelButton );
					
					if ( callback?.hasOwnProperty("onLoad") ) {
						callback.onLoad()
					}

					var table = $("#attribute-values-grid .k-grid-container .k-table");

					table.kendoSortable({
						axis: "y",
						filter: ">tbody >tr",
						hint: function(element) {
							var ele = $('<div>')
							var text = $(element).find('td.sortable').text();
							
							ele.text( text )
								.height(element.height())
								.width(element.width())
								.addClass("sortable-hint");

							return ele;

						},
						placeholder: function( element ) {
							return element.clone()
								.addClass("sortable-placeholder")
								.height(element.height())
								.width(element.width());
						},						

						end: function( event ) {
							
							if( event.newIndex != event.oldIndex ) {

								var values = viewModel.get("detailForm.data.values").data();
								var thisForm = $("#attribute-values-form");
								var status = thisForm.find(".status");

								status.html('<img src="/assets/main/img/ajax-loading.svg" width="20" height="20">');

								table.find("tr").each( function( index ) {
	
									var ele = $(this);
									var uid = ele.data("uid");
	
									for( var value of values ) {
										if ( value.get( "uid" ) == uid ) {
											value.set("orderBy", index*10 );
										}
									}
								
								});

								NM.util.ajax({ 
									method: "POST",
									url: "/manager/ajax/attributes/" + id + "/values/order",
									data: JSON.stringify( viewModel.get("detailForm.data.values").data() ),
									callback: {
										done: function( xhr ) {
											status.html("<span class='green'>Ordinamento salvato.</span> ");
											console.log("ordered!")
										}
									}
								})

							}
						}

					});
				}
			}
		})				
	}

    pub.open = function( { id, callback } ) {

		viewModel.set("detailForm.action", "create");

		if( id.length ) {
			viewModel.set("detailForm.action", "update");

			viewModel.set("callback.onSave", callback?.onSave);
			viewModel.set("callback.onSave", callback?.onSave);
	
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

		} else {
			NM.util.openModal( $("#attribute-detail-values-modal") );
			return;
		}



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
