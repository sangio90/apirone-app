component extends="coldbox.system.Interceptor"{

    function preProcess( event, data, buffer, rc, prc ){

        if ( !structKeyExists( prc, 'currentRoutedModule') ) {

            cflocation( url="/manager/login", addtoken="false" );

        }

        event.prc.eventId = LCase( CreateUUID() );

        canAccess( event );

        var module = prc.currentRoutedModule;
        var model = getModel();

        prc.isDev  = request.isDev();

        /* paging */
        param url.page = 1;
        param url.count = 15;

        /*
            API module
        */
        if ( module == "api" ) {

            storeRequest( event )

            var svc = model.getInstance("APIService");

            try {

                var authToken = Trim( GetHttpRequestData().Headers.authorization.replace("Bearer", "") );  

                //verticale
                if ( authToken != "9e39d8edd05940ddab24411338e9def857679e76978041e29a1d7f956aa0be5d" ) { 

                    return arguments.event.renderData(data="Not Authorized. Token not valid.", statusCode="401", statusText="Unauthorized")
                            .noExecution();
            
                }

            } catch( e ) {
                return arguments.event.renderData(data="Not Authorized.", statusCode="401", statusText="Unauthorized")
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

            prc.page = {};  //current js config write in current html page
            prc.jsScripts = []; //current js file for current html page

            prc.user = session.user;

            request.lang = prc.user.getAccount()?.getLang() ?: loadDefaultLang();

            prc.lang = request.lang;
            prc.subtitle  = "";

            prc.config = getGlobalConfiguration();  //js global config
            //prc.staticVersion = 20241127;
            prc.staticVersion = prc.isDev ? RandRange(1000, 9999) : 20250214;            

        }

    }

    function postEvent( event, data, buffer, rc, prc ){

        if ( prc.keyExists("currentRoutedUrl") AND ( 
                prc.currentRoutedURL.listContains( "ajax/" ) OR prc.currentRoutedURL.listContains( "api/" )  
            ) ) {

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

                    var code = 200;

                    if ( result.getStatus() == "ERROR" ) {
                        code = 400
                    }

                    event
                        .renderData( data=result, contentType="text/json", type="json", statusCode=code )
                        .noExecution();

                } else {

                    var bean = new "#path#"();

                    bean.setUuid( event.prc.eventId );
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

    private function hostCanAccess() {

        var host = ListFirst( cgi.http_host, ':' );
        var authorizedHosts = "test.apirone.cc,www.apirone.cc,apirone.cc,www.apirone.local,apirone.local,127.0.0.1";

        if( !ListFind( authorizedHosts, host ) ){

            setUnauthorizedMessage( message="Unauthorized host [#host#]" );

        }

    }

    private function userAgentCanAccess() {

        var userAgentBlocked = "curl,python,libwww-perl,wget,badbot";

        var ua = cgi.HTTP_USER_AGENT;

        for( var thisUA in userAgentBlocked ) {

            if ( ua CONTAINS thisUA ) {

                setUnauthorizedMessage( message="Unauthorized userAgent [#ua#]" );
                abort;

            }

        }

    }

    private function setUnauthorizedMessage( required String message ) {

        echo( arguments.message );
        cfheader(statusCode="404", statusText="Not found");

        FileAppend( ExpandPath("/../repository/private/logs/secure.log"), "#now()# - #arguments.message# #chr(13)##chr(10)#" );
        abort;

    }

    private function canAccess( event ) {

        hostCanAccess();
        userAgentCanAccess();

        var currentEvent = arguments.event.getContext().event;

        var allowedEvents = DeserializeJSON( FileRead( ExpandPath("/config/allowedEvents.json.cfm") ) );

        var allowedEventsForUnlogged = allowedEvents.forUnlogged;
        var allowedEventsForCustomer = ArrayMerge(allowedEvents.forUnlogged, allowedEvents.forCustomer);

        if ( event.getCurrentModule() == "manager" ) {

            if ( session.user.isLogged() ) {

                if( session.user.getRole().getId() == "CST" ) {

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

    private String function storeRequest( required event, required prefix="api", required service="apirone" ) {

        var code = "#arguments.prefix#_" & DateTimeFormat(now(), 'yyyy-mm-dd_HH-nn-ss') & '_' & RandRange(0, 99999);
        var rc.uuid = "#arguments.prefix#_" & DateTimeFormat(now(), 'yyyy-mm-dd_HH-nn-ss') & '_' & RandRange(0, 99999);
        var dayPath = DateTimeFormat(now(), 'yyyy/mm');
        var response = "";

        var thisRequest = GetHttpRequestData();

        var body = thisRequest.keyExists("content") ? thisRequest.content : "not-exists";

        var meta = {
            "apiKey"    = "not-exists",
            "eventName" = event.getContext().event,
            "route"     = event.getPrivateContext().currentRoutedURL,
            "method"    = thisRequest.method,
            "eventId"   = event.prc.eventId
        };

        if( thisRequest.keyExists("headers") ) {
            if ( thisRequest.headers.keyExists("authorization") ) {
                meta.apiKey = Trim( Replace( thisRequest.headers.authorization, "Bearer", "" ) );
            }
        }

        cffile( action="append" file="#ExpandPath('/../repository/private/logs/api.log')#" output="#now()#;#cgi.REMOTE_ADDR#;#cgi.HTTP_USER_AGENT#;#meta.route#;#meta.eventName#;#meta.method#;#meta.apiKey#" );

        // TODO: nalla path "service" o "api"?
        var thisPath = ExpandPath("/../repository/private/api/#arguments.service#/#dayPath#");

        DirectoryCreate( thisPath, true, true );

        savecontent variable="report" {
            echo("<h2>ID: #code#</h2><br>Data: #now()#");

            echo("<h3>Meta</h3>");
            cfdump( var="#meta#" label="meta" );

            echo("<h3>Request</h3>");
            cfdump( var="#body#" label="Request body" );
            
            echo("<h3>Response</h3>");
            cfdump( var="#response#" label="Response" );

            echo("<h3>CGI</h3>");
            cfdump( var="#cgi#" label="CGI" );
        }

        FileWrite( "#thisPath#/#code#.html", report );
        
        return code;

    }
        
}
