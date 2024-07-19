component extends="coldbox.system.Interceptor"{
	
    function preProcess( event, data, buffer, rc, prc ){

        if ( !structKeyExists( prc, 'currentRoutedModule') ) {

            cflocation( url="/public/home", addtoken="false" );

        }

        //TODO: add here canAccess() from Wineshipping

        var module = "prc.currentRoutedModule";
	    
        var model = server[ "wireBox-apirone" ];

        /*
            API module
        */
        if ( module == "api" ) {
        
            var svc = model.getInstance('APIService');

            try {

                var authHeader = ToString( 
                    ToBinary(  
                        Trim( 
                            GetHttpRequestData().Headers.authorization.replace('Bearer', '')
                            ) 
                        ) 
                    );

                var check = svc.login( accountId = ListFirst( authHeader, ':' ), apiKey = ListLast( authHeader, ':') );
                
                if ( check.getStatus() != 'AUTH' ) {
                    return arguments.event.renderData(data="#check.getMessage()#",statusCode="401",statusText="Unauthorized")
                                    .noExecution();
                }

            } catch( e ) {
                // Break if not base64
                return arguments.event.renderData(data="Not Authorized",statusCode="401",statusText="Unauthorized")
                    .noExecution();

            }
        }

        
        /*
            MANAGER module
        */
        if ( module == "manager" ) {

            /*

            var allowedEvents = "manager:AuthController.login,manager:AuthController.doLogin,manager:AuthController.logout";

            // se non sono loggato, e non un evento ammesso
            if ( !session.user.isLogged() AND !ListFindNoCase( allowedEvents, event.getContext().event ) ) {

                flash.put('message','Sessione scaduta. Fai il login.');
                relocate( uri="/manager/login", postProcessExempt=false, addToken=false );
                
            }
            */
        
        }

        var config = model.getInstance("Configuration").get();

        //TODO: set all  private value

        prc.user = session.user;
        prc.isDev = ( ( ListLast( cgi.SERVER_NAME, "." ) IS "local" ) OR cgi.SERVER_NAME EQ "localhost" );
        prc.i18n = model.getInstance("i18nService");
        prc.config = {};//TODO: not all Configuration.cfc please!
        prc.staticVersion = prc.isDev ? RandRange(1000, 9999) : 20240530;

        //arguments.event.setValue( "user", session.user );
        //arguments.event.setValue( "isDev", ( ListLast( cgi.SERVER_NAME, "." ) IS "local" ) OR cgi.SERVER_NAME EQ "localhost" );
        //arguments.event.setValue( "configInLine",  { "variantTypeDefault": config.get('variantTypeDefault') } );

        //arguments.event.setPrivateValue( "staticVersion",  prc.isDev ? RandRange(1000, 9999) : 20240409 );

        prc.jsScripts = [];
        
    }

    function postEvent( event, data, buffer, rc, prc ){

    }

}
