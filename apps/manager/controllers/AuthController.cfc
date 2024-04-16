component extends="com.apirone.core.controller.AbsController" {

    function login( event, rc, prc ){

        var user = arguments.event.getValue( "User" );

        //prc.config = getConfiguration().get();
        rc.email = StructKeyExists( cookie, "email" ) ? cookie.email : '';

        event.setView( "main/login" ).setLayout( "login" );

    }

    function pincode( event, rc, prc ){

        var user = arguments.event.getValue( "User" );

        event.setView( "main/pincode" ).setLayout( "login" );

    }

    function recover( event, rc, prc ){

        var user = arguments.event.getValue( "User" );

        event.setView( "main/recover" ).setLayout( "login" );

    }

    function checkPincode( event, rc, prc ) {

        var user = arguments.event.getValue( "User" );

        location("/manager/dashboard", false );

    }

    function checkRecover( event, rc, prc ) {

        var user = arguments.event.getValue( "User" );

        location("/manager/login/recover/check", false );

    }

    function checkLogin( event, rc, prc ) {

        var user = arguments.event.getValue( "User" );

        var access = getAccessManager()
            .exec( user, "auth.login", { "email" = rc.email , "pwd" = rc.pwd } );

        //cookie.email = rc.email;
        cfcookie( name="email", value="#rc.email#", expires="15", preservecase=true );

        if ( access.getStatus() )  {

            super.setAuthUser( access.getAccount() );
            
            //location("/manager/dashboard", false );
            relocate( uri="/manager/login/pincode", postProcessExempt=false, addToken=false );

        } else {

            flash.put('message','Login e/o password errate.');

            //TODO Report Ortus: 
            // - only with "/manager/login" it location to "index.cfm?/manager/login"
            // - with "uri" work fine, but raise an exception. Work adding "postProcessExempt=false"
            relocate( uri="/manager/login", postProcessExempt=false, addToken=false );

        }

        rc.email = StructKeyExists(cfcookie, "email") ? cfcookie.email : '';

        relocate( uri="/manager/login", postProcessExempt=false, addToken=false );

    }

    function logout( event, rc, prc ) {

        super.logout();
    
        location("/manager/login?msg=disconnected", false );

    }

}
