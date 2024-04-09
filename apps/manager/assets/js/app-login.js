ZB.login = ZB.login || {};
//ZB.login.fields = ZB.fields || {};

ZB['login-fields'] = {
	loginForm: $('#login-form')
}

$(document).ready(function(){

    /*
        dom inits
    */

	if ( ZB['login-fields'].loginForm.length ) {

		ZB.login.init();

	}

})

ZB.login = function() {

	var pub = {}

	pub.init = function() {

        ZB['login-fields'].loginForm.find('input')[0].focus()

		ZB['login-fields'].loginForm.validate( {
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
