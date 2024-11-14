component extends="coldbox.system.Interceptor"{
	
    function preProcess( event, data, buffer, rc, prc ){

        if ( !structKeyExists( prc, 'currentRoutedModule') ) {

            cflocation( url="/public/home", addtoken="false" );

        }

        canAccess( event );

        var module = prc.currentRoutedModule;
        var model = getModel();

        prc.isDev  = request.isDev();
	    
        /*
            API module
        */
        if ( module == "api" ) {
        
            var svc = model.getInstance('APIService');

            try {

                var authHeader = ToString( 
                    ToBinary(  
                        Trim( GetHttpRequestData().Headers.authorization.replace('Bearer', '') ) 
                        ) 
                    );

                var check = svc.login( accountId = ListFirst( authHeader, ':' ), apiKey = ListLast( authHeader, ':') );
                
                if ( check.getStatus() != "AUTH" ) {
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

        /*
            TODO: remove all "session.user"
        */

        prc.page = {};  //current js config write in current html page 
        prc.jsScripts = []; //current js file for current html page 

        prc.user = session.user;

        request.lang = prc.user.getAccount()?.getLang() ?: loadDefaultLang();
        prc.lang = request.lang;
        prc.subtitle  = "";

        prc.config = getGlobalConfiguration();  //js global config
        prc.staticVersion = prc.isDev ? RandRange(1000, 9999) : 20240530;
        
    }

    function postEvent( event, data, buffer, rc, prc ){

        if ( prc.keyExists("currentRoutedUrl") AND prc.currentRoutedURL.listContains( "ajax/" ) ) {

            /*
                here [ event.noExecution() ] not works
                https://community.ortussolutions.com/t/trouble-with-noexecution-and-pdf/9288
            */

            var path = "com.apirone.core.model.bean.AjaxResult";
            var result = event.getValue("result", "result-not-found");

            /*
                ATTENZIONE:
                non c'è result se il nome dell'hanlder nel router è sbagliato
            */

            if( IsSimpleValue( result ) AND  result == "result-not-found" ) {
                
                event.renderData( data="Result key not found", statusCode="400" )
                    .noExecution();
            
            } else {

                if ( IsInstanceOf( result, path ) ) {

                    event.renderData( data=result, contentType="text/json", type="json" )
                        .noExecution();
                
                } else {
    
                    var bean = new "#path#"();
    
                    bean.setUuid( LCase( CreateUUID() ) );
                    bean.setStatus( "SUCCESS" );
    
                    bean.setData( result );
    
                    if( !IsSimpleValue( result ) ) {
                        bean.setTotal( result.len() );
                        bean.setCount( result.len() );
                    }
    
                    event.renderData( data=bean, contentType="text/json", type="json" )
                        .noExecution()
    
                }

            }


        }

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
        };

        return result;

    }

    private Struct function getModel(){

        return server[ "wireBox-apirone" ];;

    }

    private Struct function loadDefaultLang(){

        var lang = new com.apirone.core.model.bean.Lang();

        lang.setId("IT");

        return lang;

    }

    private function canAccess( event ) {

        var currentEvent = arguments.event.getContext().event;

        var allowedEvents = DeserializeJSON( FileRead( ExpandPath("/config/allowedEvents.json.cfm") ) );

        var allowedEventsForUnlogged = allowedEvents.forUnlogged;
        var allowedEventsForCustomer = ArrayMerge(allowedEvents.forUnlogged, allowedEvents.forCustomer);

        if ( event.getCurrentModule() == "manager" ) {

            if ( session.user.isLogged() ) {

                if( session.user.getAccount().getRole().getId() == "CST" ) {

                    if( !ArrayFindNoCase( allowedEventsForCustomer, currentEvent ) ) {

                        location( "/manager/dashboard?msg=page-not-auth&event=#currentEvent#", false );
                    
                    }
                
                }

            } else {

                if( !ArrayFindNoCase( allowedEventsForUnlogged, currentEvent ) ) {

                    location( "/manager/login?msg=not-auth", false );

                }

            }

        }
 
    }

}
