component extends="coldbox.system.Interceptor"{
	
    function preProcess( event, data, buffer, rc, prc ){

        if ( !structKeyExists( prc, 'currentRoutedModule') ) {

            cflocation( url="/public/home", addtoken="false" );

        }

        //TODO: add here canAccess() from Wineshipping

        var module = prc.currentRoutedModule;
        var model = getModel();
	    
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
                // Break if not Base64
                return arguments.event.renderData(data="Not Authorized",statusCode="401",statusText="Unauthorized")
                    .noExecution();

            }
        }

        
        /*
            MANAGER module
        */
        if ( module == "manager" ) {

            var allowedEvents = "manager:AuthController.login,manager:AuthController.checkLogin,manager:AuthController.logout";

            // se non sono loggato, e non un evento ammesso
            if ( !session.user.isLogged() AND !ListFindNoCase( allowedEvents, event.getContext().event ) ) {

                flash.put("message","Sessione scaduta. Fai il login.");
                relocate( uri="/manager/login", postProcessExempt=false, addToken=false );
                
            }
        
        }

       
        //TODO: set all  private value

        prc.user   = session.user;
        prc.isDev  = request.isDev();
        prc.i18n   = model.getInstance("i18nService");
        prc.config = getGlobalConfiguration(); //js global config

        prc.page = {};  //current js config

        prc.staticVersion = prc.isDev ? RandRange(1000, 9999) : 20240530;

        prc.jsScripts = [];
        //prc.jsTemplates = [];
        
    }

    function postEvent( event, data, buffer, rc, prc ){

    }


    /*
        private methods
    */

    private Struct function getGlobalConfiguration(){

        // Select keys from Configuration.cfc 
        // Not all keys, please!
        
        var config = getModel().getInstance("Configuration").get();

        var result = {
            "appName" = config.get("appName"),
            "appVersion" = config.get("appVersion"),
            "langs" = getModel().getInstance("LangService").list()
        };

        return result;

    }

    private Struct function getModel(){

        return server[ "wireBox-apirone" ];;

    }

}
