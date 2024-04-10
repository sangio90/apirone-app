component extends="com.apirone.core.controller.AbsController" {

    function login( event, rc, prc ){

        var user = arguments.event.getValue( "User" );

        prc.config = getConfiguration().get();

        event.setView( "main/login" ).setLayout( "login" );

    }
    
    function doLogin( event, rc, prc ) {

        var user = arguments.event.getValue( "User" );

        var access = getAccessManager()
            .exec( user, "auth.login", { "email" = rc.login , "pwd" = rc.pwd } );
        

        if ( access.getStatus() )  {

            super.setAuthUser( access.getAccount() );
            
            location("/manager/dashboard", false );

        } else {

            flash.put('message','Login e/o password errate.');

            //TODO Report Ortus: 
            // - only with "/manager/login" it location to "index.cfm?/manager/login"
            // - with "uri" work fine, but raise an exception. Work adding "postProcessExempt=false"
            relocate( uri="/manager/login", postProcessExempt=false, addToken=false );

        }

    }

    function logout( event, rc, prc ) {

        super.logout();
    
        location("/manager/login?msg=disconnected", false );

    }

}
