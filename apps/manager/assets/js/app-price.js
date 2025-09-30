AP.namespace( "price" );

Object.assign( AP.price.fields, {
    modal: $( "#price-form-list-modal" ),
} );

AP.price.modal = ( function() {

    var pub = {};
	var fields = AP.price.fields;
	
    var getCurrentConfig = function() {

        var current = viewModel.get( "currentItem" );
        var baseUrl = "/manager/ajax/prices";

        var result = {
            modalTitle: "",
            modifyUrl: "",
            readUrl: ""
        };

        if( current ) {

            switch( current.type ) {

            case "product":

                result.modalTitle = "Prezzi per l'articolo: " + current.line.name + " / " + current.model.name;
                result.readUrl = baseUrl + "/products/" + current.product.id + "/prices"
                result.modifyUrl = result.readUrl;

                break;

            case "productItem": // productItem

                result.modalTitle = "Prezzi per l'attributo: " + current.attribute.name + " / " + current.attributeValue.rawValue.name;
                result.readUrl = baseUrl + "/product-items/" + current.item.id + "/prices";
                result.modifyUrl = result.readUrl;

                break;

				default:
					throw Error("Configuration [" + current.type + "] not valid" );
            }

        }

        return result;

    };	

	var viewModel = kendo.observable({
		
		currentItem: null,

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
	
	var loadList = function ( productId ) {

		NM.util.ajax( {
			method: "GET",
			url: getCurrentConfig().readUrl,
			callback: {
				done: function (xhr) {
					
				},
			},
		} );
		
	}

    pub.open = function( item ) {

        kendo.bind( fields.modal, viewModel );

        viewModel.set( "currentItem", item );

        initUpload();

    };

    return pub;
}() );
