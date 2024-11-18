AP.attribute = AP.attribute || {};

AP.attribute.fields = {
    listRoot  : $("#attribute-list-root"),
    detailRoot: $("#attribute-detail-modal"),
    detailForm: $("#attribute-detail-form"),
    valueForm : $("#attribute-values-add-form"),
    valuesForm: $("#attribute-values-form"),
}

$(document).ready(function(){

	if ( AP.attribute.fields.detailRoot.length ) {

		AP.attribute.detail.init();

	}

	if ( AP.attribute.fields.listRoot.length ) {

		AP.attribute.list.init();

	}

})

/*
	detail
*/

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

	invokeCallback = function( func ) {

		var cb = viewModel.get("callback");

		console.log("cb", cb)
		console.log("typeof", typeof cb[func] == "function" )

		if( typeof cb[func] == "function" ) {

			cb[func]()

		}

	}

	var viewModel = kendo.observable({

		detailForm: defaults.detailForm,
		valueForm: defaults.valueForm,

		categories: AP.page.categories,		
		statusList: AP.page.attributeStatusList,

		callback: {
			onCreate: undefined,
			onUpdate: undefined,
			onLoad: undefined
		},

		resetDetailForm: function() {

			var thisForm = AP.attribute.fields.detailForm;

			viewModel.set("detailForm", defaults.detailForm );

			thisForm.find(".status").html("");
			thisForm.data("validator").resetForm();

		},
		
		resetValueForm: function() {
			
			//viewModel.set("valueForm", defaults.valueForm );
			
			//AP.attribute.fields.valueForm.resetForm();

		},
		
		isValuesGridVisible: function() {

			var values = viewModel.get("detailForm.data.values");

			if ( values?.total() ) {
				return true;
			}
			
			return false;

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

			/*
			var selectedCategories = [];

			for (var category of event.data.categories)  {
				selectedCategories.push( category.id );
			}

			viewModel.set( "detailForm.data", event.data );

			viewModel.set( "detailForm.data.selectedCategories", selectedCategories );
			viewModel.set( "detailForm.title", "Modifica attributo < " + event.data.name + " >" );
			*/

		},

		new: function( event ) {

			//viewModel.set( "detailForm.data", event.data );

			//viewModel.set( "detailForm.data.selectedCategories", selectedCategories );
			viewModel.set( "detailForm.title", "Carica attributo" );

		},

		save: function() {

			var thisForm = AP.attribute.fields.detailForm;
			var status = thisForm.find(".status");

			status.html('<img src="/assets/main/img/ajax-loading.svg" width="20" height="20">');

			if( thisForm.valid() ) {

				NM.util.ajax({ 
					method: "POST", 
					url: "/manager/ajax/attributes",
					data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
					callback: {
						done: function( xhr ) {
							status.html("<span class='green'>Attributo modificato</span>");

							invokeCallback( "onUpdate" );

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

		console.log("callback", callback)
		
		viewModel.set("callback", callback )
		
		var aa = viewModel.get("callback" )
		console.log("aa", aa);

		NM.util.ajax({ 
			method: "GET", 
			url: "/manager/ajax/attributes/" + id,
			callback: {
				done: function( xhr ) {

					console.log("xhr.data.values", xhr.data)

					var valuesDataSource = new kendo.data.DataSource({
						data: xhr.data.values,
						sort: { field: "orderBy", dir: "asc" } 
					});

					delete xhr.data.values;

					var selectedCategories = [];

					for (var category of xhr.data.categories)  {
						selectedCategories.push( category );
					}
		
					viewModel.set( "detailForm.data", xhr.data );
					viewModel.set( "detailForm.data.selectedCategories", selectedCategories );
					viewModel.set( "detailForm.data.values", valuesDataSource );
					viewModel.set( "detailForm.title", "Modifica attributo <" + xhr.data.name + " >"  );
					viewModel.set( "detailForm.labelButton", "Aggiorna" );

					var cb = viewModel.get("callback");

					console.log( "cb", cb );
					
					if ( cb.hasOwnProperty("onLoad") ) {
						cb.onLoad()
					}

					NM.util.openModal( $("#attribute-detail-modal") );

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

    pub.new = function( callback ) {

		viewModel.resetDetailForm();

		NM.util.openModal( $("#attribute-detail-modal") );
		
		return;

	};


    pub.edit = function( { id, callback } ) {

		loadAttribute( { id: id, callback: callback } );

    };

	pub.init = function() {

		console.log("AP.attribute.detail:init")

		kendo.bind( AP.attribute.fields.detailRoot, viewModel );

		var valueForm = AP.attribute.fields.valueForm;
		var detailForm = AP.attribute.fields.detailForm;

		detailForm.validate( {
			onfocusout: function( element ) {
				$(element).valid();
			},
			rules: {
				attr: {
					required: true
				}
			},
			messages: {
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



/*
	list
*/

AP.attribute.list = function() {

	var detailApp = AP.attribute.detail;

	var pub = {}

	var dataSources = {
		rows: NM.kendo.dataSource( { url: "/manager/ajax/attributes" } )
	}

	var viewModel = kendo.observable({

		rows: dataSources.rows,

		new: function() {

			detailApp.new();

			return false;

		},		

		edit: function( event ) {

			detailApp.edit( { 
				id: event.data.id,
				callback: {
					onLoad: function() {
						console.log("CARICATO!")
					},
					onUpdate: function() {
						viewModel.rows.read()
						console.log("AGGIORNATO")
					}
				}
			} );

			return false;

		},		

		search: function() {

			return false;

		},		

    });

	pub.init = function() {

		console.log("AP.attribute.list:init")

		kendo.bind( AP.attribute.fields.listRoot, viewModel );

	}	

	return pub;

}();