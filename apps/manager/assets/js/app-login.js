AP.login = AP.login || {};
//ZB.login.fields = ZB.fields || {};

AP['login-fields'] = {
	loginForm: $('#login-form')
}

$(document).ready(function(){

    /*
        dom inits
    */

	if ( AP['login-fields'].loginForm.length ) {

		AP.login.init();

	}

})

AP.login = function() {

	var pub = {}

	pub.init = function() {

        AP['login-fields'].loginForm.find('input')[0].focus()

		AP['login-fields'].loginForm.validate( {
			onfocusout: function( element ) {
				$(element).valid();
			},
			rules: {
				login: {
					required: true
				},
				pwd: {
					required: true,
				},
			},
			messages: {
				login: {
					required: "Inserisci la tua login"
				},
				pwd: {
					required: "Inserisci la tua password",
				},
			},
		
		} );

	}	

    return pub;

}();
