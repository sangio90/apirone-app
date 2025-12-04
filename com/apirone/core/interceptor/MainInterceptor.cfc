component extends="coldbox.system.Interceptor" {

	function preProcess(
		event,
		data,
		buffer,
		rc,
		prc
	){

		if ( 
			( prc.keyExists( "currentRoutedURL" ) AND prc.currentRoutedURL == "manager/" ) 
			OR 
			( !prc.keyExists( "currentRoutedModule" ) ) 
		) {
			location( url = "/manager/login", addToken = false );
		}

		cfheader( name = "Access-Control-Allow-Origin", value = "*" );
		cfheader( name = "Access-Control-Allow-Methods", value = "GET, POST, OPTIONS" );
		cfheader( name = "Access-Control-Allow-Headers", value = "Content-Type, X-Requested-With" );

		event.prc.eventId = CreateUUID()

		// canAccess( event );

		var module = prc.currentRoutedModule;
		var model  = getContainer();

		prc.isDev = request.isDev();

		/* paging */
		param url.page  = 1;
		param url.count = 15;

		/*
            API module
        */



		/*
            MANAGER module
        */
		if ( module == "manager" ) {
			prc.page     = {}; // current js config write in current html page
			prc.jsFiles  = []; // current js file for current html page
			prc.cssFiles = []; // current css file for current html page

			prc.user = session.user;

			request.lang = prc.user.getAccount()?.getLang() ?: loadDefaultLang();

			prc.lang     = request.lang;
			prc.subtitle = "";

			prc.config        = getGlobalConfiguration(); // js global config
			prc.staticVersion = ( prc.isDev ? RandRange( 1000, 9999 ) : DateFormat( Now(), "yyyymmdd" ) ) & application.counter;
		}
	}

	function postEvent(
		event,
		data,
		buffer,
		rc,
		prc
	){
		if (
			prc.keyExists( "currentRoutedUrl" ) AND (
				prc.currentRoutedURL.listContains( "ajax/" ) OR prc.currentRoutedURL.listContains( "api/" )
			)
		) {
			var result = event.getValue( "result", "result-not-found" );

			var statusCode = 200;
			var bean       = new com.apirone.core.model.bean.AjaxResult();

			bean.setUuid( event.prc.eventId );
			bean.setData( "Result not found" );

			if ( IsInstanceOf( result, "com.apirone.core.model.bean.AjaxResult" ) ) {
				bean = result;
			} else if ( IsInstanceOf( result, "cbvalidation.models.result.ValidationResult" ) ) {
				statusCode = 400;
				var errors = exportErrors( result.getAllErrorsASStruct() );

				bean.setStatus( "INVALID" );
				bean.setData( errors );
				bean.setCount( errors.len() );
				bean.setTotal( errors.len() );
			} else {
				bean.setStatus( "SUCCESS" );
				bean.setData( result );
				bean.setCount( IsArray( result ) ? result.len() : 1 );
				bean.setTotal( IsArray( result ) ? result.len() : 1 );
			}

			event
				.renderData(
					statusCode  = statusCode,
					data        = bean,
					contentType = "application/json",
					type        = "json"
				)
				.noExecution();
		}
	}

	/*
        private methods
    */

	function exportErrors( required struct errors ){
		var newErrors = {};

		for ( var key in errors ) {
			var arr = [];
			for ( var err in errors[ key ] ) {
				var newErr = {};
				if ( err.keyExists( "message" ) && Len( Trim( err.message ) ) ) {
					newErr[ "message" ] = err.message;
				}

				if ( err.keyExists( "rejectedValue" ) && Len( Trim( err.rejectedValue ) ) ) {
					newErr[ "rejected" ] = err.rejectedValue;
				}

				if ( err.keyExists( "validationType" ) && Len( Trim( err.validationType ) ) ) {
					newErr[ "type" ] = err.validationType;
				}

				if (
					err.keyExists( "errorMetadata" ) && !IsSimpleValue( err.errorMetadata ) && !IsNull(
						err.errorMetadata
					)
				) {
					newErr[ "metadata" ] = err.errorMetadata;
				}

				if ( err.keyExists( "field" ) && Len( Trim( err.field ) ) ) {
					newErr[ "field" ] = err.field;
				}

				// aggiungi solo se almeno una chiave è presente
				if ( StructCount( newErr ) ) {
					ArrayAppend( arr, newErr );
				}
			}
			newErrors[ key ] = arr;
		}
		return newErrors;
	}

	private Struct function getGlobalConfiguration(){
		// Select keys from Configuration.cfc
		// Not all keys, please!

		var config = getContainer().getInstance( "Configuration" ).get();

		var result = {
			"user"       = { "id" = session.user.getId() },
			"appName"    = config.get( "appName" ),
			"appVersion" = config.get( "appVersion" ),
			"account"    = {
				"shortId" = session.user.getAccount()?.getShortId() ?: "not-exists"
			}
		};

		return result;
	}

	private Struct function getContainer(){
		return server[ "wireBox-apirone" ];
	}

	private Struct function loadDefaultLang(){
		var lang = new com.apirone.core.model.bean.Lang();

		lang.setId( "IT" );

		return lang;
	}

	private function hostCanAccess(){
		var host            = ListFirst( cgi.http_host, ":" );
		var authorizedHosts = "test.apirone.cc,www.apirone.cc,apirone.cc,www.apirone.local,apirone.local,127.0.0.1";

		if ( !ListFind( authorizedHosts, host ) ) {
			setUnauthorizedMessage( message = "Unauthorized host [#host#]" );
		}
	}

	private function userAgentCanAccess(){
		var userAgentBlocked = "curl,python,libwww-perl,wget,badbot";

		var ua = cgi.HTTP_USER_AGENT;

		for ( var thisUA in userAgentBlocked ) {
			if ( ua CONTAINS thisUA ) {
				setUnauthorizedMessage( message = "Unauthorized userAgent [#ua#]" );
				abort;
			}
		}
	}

	private function setUnauthorizedMessage( required String message ){
		Echo( arguments.message );
		cfheader( statusCode = "404", statusText = "Not found" );

		FileAppend(
			ExpandPath( "/../repository/private/logs/secure.log" ),
			"#Now()# - #arguments.message# #Chr( 13 )##Chr( 10 )#"
		);
		abort;
	}

	// TODO: use this in SecurityInterceptor
	private String function storeRequest(
		required event,
		required prefix  = "api",
		required service = "apirone"
	){
		var code = "#arguments.prefix#_" & DateTimeFormat( Now(), "yyyy-mm-dd_HH-nn-ss" ) & "_" & RandRange( 0, 99999 );

		var dayPath  = DateTimeFormat( Now(), "yyyy/mm" );
		var response = "";

		var thisRequest = GetHTTPRequestData();

		var body = thisRequest.keyExists( "content" ) ? thisRequest.content : "not-exists";

		var meta = {
			"apiKey"    = "not-exists",
			"eventName" = event.getContext().event,
			"route"     = event.getPrivateContext().currentRoutedURL,
			"method"    = thisRequest.method,
			"eventId"   = event.prc.eventId
		};

		if ( thisRequest.keyExists( "headers" ) ) {
			if ( thisRequest.headers.keyExists( "authorization" ) ) {
				meta.apiKey = Trim(
					Replace(
						thisRequest.headers.authorization,
						"Bearer",
						""
					)
				);
			}
		}

		cffile(
			action = "append",
			file   = "#ExpandPath( "/../repository/private/logs/api.log" )#",
			output = "#Now()#;#cgi.REMOTE_ADDR#;#cgi.HTTP_USER_AGENT#;#meta.route#;#meta.eventName#;#meta.method#;#meta.apiKey#"
		);

		// TODO: nalla path "service" o "api"?
		var thisPath = ExpandPath( "/../repository/private/api/#arguments.service#/#dayPath#" );

		DirectoryCreate( thisPath, true, true );

		savecontent variable="report" {
			Echo( "<h2>ID: #code#</h2><br>Data: #Now()#" );

			Echo( "<h3>Meta</h3>" );
			cfdump( var = "#meta#", label = "meta" );

			Echo( "<h3>Request</h3>" );
			cfdump( var = "#body#", label = "Request body" );

			Echo( "<h3>Response</h3>" );
			cfdump( var = "#response#", label = "Response" );

			Echo( "<h3>CGI</h3>" );
			cfdump( var = "#cgi#", label = "CGI" );
		}

		FileWrite( "#thisPath#/#code#.html", report );

		return code;
	}

}
