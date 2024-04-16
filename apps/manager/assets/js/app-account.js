AP.account = AP.account || {};

AP.account.fields = {
    listRoot: $('#account-list-root'),
    detailRoot: $('#account-detail-form')
}

$(document).ready(function(){

	if ( AP.account.fields.listRoot.length ) {

		AP.product.detail.init();

	}

})

ZB.product.detail = function() {

    var pub = {};

	pub.showFirstVariant = function( e )  {

		//console.log("showFirstVariant");

		var type = ZB.product.fields.detailForm.find('#variantTypeId').val();

		//console.log("type", type);
		//console.log("ZB.config.variantTypeDefault", ZB.config.variantTypeDefault)

		if ( type == ZB.config.variantTypeDefault ) {

			$('#show-first-variant').show();
			$('#show-first-variant-note').hide();

		} else {

			$('#show-first-variant').hide();
			$('#show-first-variant-note').show();

		}

	}


	pub.init = function() {

        console.log("account:init");

		//pub.showFirstVariant();

		ZB.product.fields.detailForm.validate( {
            submitHandler: function(form) {
                form.submit();
            },
			onfocusout: function( element ) {
				$(element).valid();
			},
			rules: {
				code: {
					required: true,
					checkCode: true,
				},
				name: {
                    required: true,
                },
				companyId: {
                    required: true,
                },
				quantity: {
                    required: true,
                    integer: true
                },
				price: {
                    required: true,
                    number: true
                },
				variantTypeId: {
                    required: true
                },
				statusId: {
                    required: true
                }
			},
			messages: {
				code: {
					required: "Codice richiesto",
					checkCode: "Formato non corretto",
				},
				name: "Descrizione richiesta",
                quantity: "E' richiesto un valore intero",
                price: "E' richiesto un valore numerico",
                companyId: "Seleziona una azienda",
                variantTypeId: "Seleziona un tipo di variante",
                statusId: "Stato richiesto"
			},
		
		} );

		//kendo.bind( ZB.product.fields.root, viewModel )
        
	}	

    return pub;

}();
