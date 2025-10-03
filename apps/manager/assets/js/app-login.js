AP.login = AP.login || {};

AP["login-fields"] = {
    loginForm: $( "#login-form" )
};

$( document ).ready( function(){

    /*
        dom inits
    */

    if ( AP["login-fields"].loginForm.length ) {

        AP.login.init();

    }

} );

AP.login = ( function() {

    var pub = {};

    pub.init = function() {

        AP["login-fields"].loginForm.find( "input" )[0].focus();

        AP["login-fields"].loginForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
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

    };

    pub.togglePwd = function() {

        var thisForm = AP["login-fields"].loginForm;

        var pwd = thisForm.find( "input[name=pwd]" );
        var label = thisForm.find( "#label-change-type" );

        var type = pwd.prop( "type" );

        if ( type == "password" ) {

            pwd.prop( "type", "text" );
            label.html( "Nascondi password" );

        } else {

            pwd.prop( "type", "password" );
            label.html( "Mostra password" );

        }

    };

    return pub;

}() );
