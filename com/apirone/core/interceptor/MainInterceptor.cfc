component extends="coldbox.system.Interceptor"{
	
    function preProcess( event, data, buffer, rc, prc ){

        if ( !structKeyExists( prc, 'currentRoutedModule') ) {

            cflocation( url="/public/home", addtoken="false" );

        }

        canAccess( event );

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

       
        //TODO: set all  private value

        prc.user   = session.user;
        prc.isDev  = request.isDev();
        prc.config = getGlobalConfiguration(); //js global config

        prc.page = {};  //current js config

        prc.staticVersion = prc.isDev ? RandRange(1000, 9999) : 20240530;

        prc.jsScripts = [];
        //prc.jsTemplates = [];
        
    }

    function postEvent( event, data, buffer, rc, prc ){

        if ( prc.keyExists("currentRoutedUrl") AND prc.currentRoutedURL.listContains( "ajax/" ) ) {

            /*
                here [ event.noExecution() ] not works
                https://community.ortussolutions.com/t/trouble-with-noexecution-and-pdf/9288
            */

            var path = "com.apirone.core.model.bean.AjaxResult";
            var bean = new "#path#"();

            var result = event.getValue("result", "result-not-found");

            /*
                ATTENZIONE:
                non c'è result se il nome dell'hanlder nel router è sbagliato
            */

            if ( 
                IsInstanceOf( result, path ) 
                OR
                IsSimpleValue( result )
                ) {

                event.renderData( data=result, contentType="text/json", type="json" )
                    .noExecution();
            
            } else {

                bean.setTotal( result.len() );
                bean.setCount( result.len() );
                bean.setData( result );

                event.renderData( data=bean, contentType="text/json", type="json" )
                    .noExecution()

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
            //"langs" = getModel().getInstance("LangService").list()
        };

        return result;

    }

    private Struct function getModel(){

        return server[ "wireBox-apirone" ];;

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
