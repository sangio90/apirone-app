AP.price = AP.price || {};
AP.fields.price = AP.fields.price || {};

AP.fields.price = {
    detailList: $( "#price-form-list-detail" ),
};

$( document ).ready( function(){

    if ( AP.fields.price.detailRoot.length ) {
        AP.price.modal.init();
    }

} );

AP.price.modal = ( function() {

    var pub = {};
    var fields = AP.fields.price;

    var viewModel = kendo.observable( {

        save: function( event ) {

            var manageForm = AP.fields.price.manageForm;
            var status = manageForm.find( ".status" );

            var manageForm = AP.fields.price.manageForm;

            manageForm.validate( {
                onfocusout: function( element ) {
                    $( element ).valid();
                },
                rules: {
                    categoryId: {
                        required: true
                    },
                    lineId: {
                        required: true
                    },
                    typeId: {
                        required: true
                    },
                    newAmount: {
                        number: true,
                        required: true
                    },
                },
                messages: {
                    categoryId: {
                        required: "Seleziona una categoria",
                    },
                    lineId: {
                        required: "Seleziona una linea",
                    },
                    typeId: {
                        required: "Seleziona un tipo di prezzo",
                    },
                    newAmount: {
                        number: "Importo non numerico",
                        required: "Inserisci un importo",
                    },
                },

            } );


            if ( manageForm.valid() ) {

                status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/prices/reassign",
                    data: JSON.stringify( manageForm.serializeJSON() ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
                                // NM.util.autoHideMessage(status, "<span class='green'>Prezi salvati</span>");
                                AP.widget.notify( "success", "Prezzi salvati con successo" );
                                status.html( "" );
                            }
                        },
                    },
                } );
            }

            return false;

		};

	});
	
	var loadList = function () {

		NM.util.ajax( {
			method: "POST",
			url: "/manager/ajax/prices",
			data: JSON.stringify( manageForm.serializeJSON() ),
			callback: {
				done: function( xhr ) {
					if ( xhr.status == "SUCCESS" ) {
						// NM.util.autoHideMessage(status, "<span class='green'>Prezi salvati</span>");
						AP.widget.notify( "success", "Prezzi salvati con successo" );
						status.html( "" );
					}
				},
			},
		} );

		
	}

    pub.multiEdit = function() {


        viewModel.multiEdit(  );

    };

    pub.init = function() {

        kendo.bind( AP.fields.price.manageRoot, viewModel );


    };

    return pub;
}() );
