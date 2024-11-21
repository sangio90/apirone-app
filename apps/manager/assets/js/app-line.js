AP.line = AP.line || {};

AP.line.fields = {
    listRoot: $("#line-list-root"),
    detailRoot: $("#line-detail-modal"),
    detailForm: $("#line-detail-form"),
    searchListForm: $("#line-grid-search-form"),
    combinationsRoot: $("#line-combinations-root")
}

$(document).ready(function(){

	if ( AP.line.fields.listRoot.length ) {

	    AP.line.list.init();

	}

	if ( AP.line.fields.combinationsRoot.length ) {

	    AP.line.combinations.init();

	}

	if ( AP.line.fields.detailRoot.length ) {

	    AP.line.detail.init();

	}

})


AP.line.detail = function() {

	var pub = {}

	var defaultDetailForm = {
		data: {
			id: "",
			code: "",
			name: "",
			category: {
                id: ""
            },
			thickness: {
                id: ""
            },
			status: {
				id: "ACT"
			}
		},
		
        statuses: AP.page.statuses,
		categories: AP.page.categories,
		thicknesses: AP.page.thicknesses,

		title: "Carica linea"
	};

	var fireCallback = function( func ) {

		var callbackList = viewModel.get("callback");

        console.log("callbackList:func", func)
        console.log("callbackList", callbackList)

		var exists = callbackList?.hasOwnProperty( func );

        console.log("callbackList:exists", exists)

		if( exists ) {

			var thisCallback = callbackList[ func ]

			if( typeof thisCallback == "function" ) {
				thisCallback()
			}
		}

	}

	var viewModel = kendo.observable({

        detailForm: defaultDetailForm,

        callback: {
			onCreate: undefined,
			onUpdate: undefined,
			onLoad: undefined
		},
        
		resetForm: function () {
			viewModel.set("detailForm", defaultDetailForm);
		},

        edit: function( event ) {
        },

            /*
        new: function( event ) {
            return false;

        },
        */

        save: function( event ) {

			var thisForm = AP.line.fields.detailForm;
			var status = thisForm.find(".status");

			status.html('<img src="/assets/main/img/ajax-loading.svg" width="20" height="20">');

			if(thisForm.valid()) {

				NM.util.ajax({
					method: "POST",
					url: "/manager/ajax/lines",
					data: JSON.stringify(viewModel.get("detailForm.data")),
					callback: {
						done: function (xhr) {
							
							if( xhr.status == "SUCCESS" ) {

								NM.util.autoHideMessage( status, "<span class='green'>Linea salvata</span>" );

								setTimeout( () => $("#line-detail-modal").modal("hide"), 1000 );

                                fireCallback("onSave");

							}

						}
					}
				});

			}

            return false;

        },

	});

	pub.new = function( { onSave } ) {

        if ( onSave ) {
            viewModel.set("callback.onSave", onSave)
        }

        viewModel.resetForm();

        NM.util.openModal( AP.line.fields.detailRoot );


    },

	pub.init = function() {

        console.log("detail:init")

        kendo.bind( AP.line.fields.detailRoot, viewModel );

		var detailForm = AP.line.fields.detailForm;

		detailForm.validate({
			onfocusout: function (element) {
				$(element).valid();
			},
			rules: {
				code: {
					required: true,
					checkCode: true,
					remote: {
						url: "/manager/ajax/lines/code-exists",
						data: { id: function () { return  viewModel.get("detailForm.data.id"); } },
						dataFilter: function (xhr) {
							var json = JSON.parse(xhr);
							return json.data == false;
						}
					}
				}
			},
			messages: {
				code: {
					required: "Codice richiesto",
					checkCode: "Solo numeri, lettere, trattino o trattino basso",
					remote: "Il codice esiste"
				}
			},

		});

	}	

    return pub;
}();


AP.line.list = function() {

	var pub = {}

    var detailApp = AP.line.detail;

	var dataSources = {
		items: NM.kendo.dataSource( { url: "/manager/ajax/lines" } )
	}

	var viewModel = kendo.observable({
		rows: dataSources.items,
        
        search: function( event ) {

            var thisForm = AP.line.fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params )

            return false;

        },

        new: function( event ) {

            console.log("detailApp", detailApp)

            var onSave = function() {
                console.log("onSave");
                viewModel.get("rows").read();
            }

            detailApp.new( { onSave: onSave } );

            return false;

        },

        open: function( event ) {

            var id = event.data.id
            window.open( "/manager/lines/" + id, '_blank').focus();

        },

		print: function( item ) {

            window.open('/manager/lines/print', '_blank');

            return false;
		},

		combinations: function( event ) {

            var id = event.data.id
            window.open( "/manager/lines/" + id + "/combinations", '_blank').focus();

            return false;
		},


		attributes: function( event ) {

            /*
                note: redirect in controller to first combination
            */

            var id = event.data.id
            window.open( "/manager/lines/" + id + "/attributes", '_blank').focus();

            return false;
		},


	});

	pub.init = function() {

        console.log("list:init")

        kendo.bind( AP.line.fields.listRoot, viewModel );

	}	

    return pub;
}();


AP.line.combinations = function() {

    var pub = {};

    var changeStatus = function( status, event ) {

        //active 
        var method = "POST";
        var classToShow = "active";
        var classToHide = "deactive";
        var message = "Combinazione salvata";

        //deactive
        if ( status == "deactive" ) {
            method = "DELETE"
            classToShow = "deactive";
            classToHide = "active";
            message = "Combinazione rimossa";
        }

        var status = $("#line-combinations-status");
        var values = $(event.currentTarget).data( "values" );

        status.html('<img src="/assets/main/img/ajax-loading.svg" width="20" height="20">');

        var size = values.split( "__" )[0];
        var finish = values.split( "__" )[1];

        NM.util.ajax({ 
            method: method, 
            url: "/manager/ajax/lines/" + AP.page.line.id + "/combinations",
            data: JSON.stringify( { 
                    sizeId: size,
                    finishId: finish
                } 
            ),
            callback: {
                done: function( xhr ) {

                    if( xhr.status == "SUCCESS" ) {

                        var payload = xhr.data.payload;

                        var button = $("button[data-values='" + values +"']");

                        button.filter( "." + classToShow ).show();
                        button.filter( "." + classToHide ).hide();

                        status.html("<span class='green'>" + message + "</span> ");

                    }

                }
            }
        })
        
        return false;
    
    }

	var viewModel = kendo.observable({

        activate: function( event ) {

            event.preventDefault();

            changeStatus("active", event);

		},

        deactivate: function( event ) {
            
            event.preventDefault();

            bootbox.confirm({
                title: "Conferma eliminazione",
                message: "Sei sicuro di voler cancellare questa combinazione?",
                buttons: {
                    confirm: {
                        label: 'Si, confermo',
                        className: 'btn-primary'
                    },
                    cancel: {
                        label: 'No, chiudi',
                        className: 'btn-danger'
                    }
                },
                callback: function (result) {
                    if( result ) {
                        changeStatus("deactive", event);
                    }
                }
            });
        },


	});    

	pub.init = function() {

		kendo.bind( AP.line.fields.combinationsRoot, viewModel )
        
	}	

    return pub;

}();
