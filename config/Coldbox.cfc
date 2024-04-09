component{

	function configure() {
		/**
		 * --------------------------------------------------------------------------
		 * ColdBox Directives
		 * --------------------------------------------------------------------------
		 * Here you can configure ColdBox for operation. Remember tha these directives below
		 * are for PRODUCTION. If you want different settings for other environments make sure
		 * you create the appropriate functions and define the environment in your .env or
		 * in the `environments` struct.
		 */
		coldbox = {
			// Application Setup
			appName                  : getSystemSetting( "APPNAME", "zerobenefit" ),
			eventName                : "event",
			// Development Settings
			reinitPassword           : "",
			reinitKey                : "fwreinit",
			handlersIndexAutoReload  : true,
			// Implicit Events
			defaultEvent             : "MainController.home",
			requestStartHandler      : "",
			requestEndHandler        : "",
			applicationStartHandler  : "",
			applicationEndHandler    : "",
			sessionStartHandler      : "",
			sessionEndHandler        : "",
			missingTemplateHandler   : "",
			// Extension Points
			applicationHelper        : "",
			viewsHelper              : "/apps/public/helpers/viewHelpers.cfm",
			//modulesExternalLocation  : [],
			modulesExternalLocation  : [ "/apps" ],
			viewsExternalLocation    : "",
			layoutsExternalLocation  : "/layouts",
			//handlersExternalLocation : "apps.manager.controllers",
			requestContextDecorator  : "",
			controllerDecorator      : "",
			// Error/Exception Handling
			invalidHTTPMethodHandler : "public:UtilController.invalidMethod",
			//exceptionHandler         : "public:MainController.error",
			invalidEventHandler      : "public:UtilController.notFound",
			customErrorTemplate      : "/coldbox/system/exceptions/BugReport.cfm",
			// Application Aspects
			handlerCaching           : false,
			eventCaching             : false,
			viewCaching              : false,
			// Will automatically do a mapDirectory() on your `models` for you.
			autoMapModels            : false,
			// Auto converts a json body payload into the RC
			jsonPayloadToRC          : true
		};

		/**
		 * --------------------------------------------------------------------------
		 * Custom Settings
		 * --------------------------------------------------------------------------
		 */
		settings = {
			key: "MyValue"
		};

		/**
		 * --------------------------------------------------------------------------
		 * Environment Detection
		 * --------------------------------------------------------------------------
		 * By default we look in your `.env` file for an `environment` key, if not,
		 * then we look into this structure or if you have a function called `detectEnvironment()`
		 * If you use this setting, then each key is the name of the environment and the value is
		 * the regex patterns to match against cgi.http_host.
		 *
		 * Uncomment to use, but make sure your .env ENVIRONMENT key is also removed.
		 */
		
		environments = { development : "localhost,^127\.0\.0\.1" };

		/**
		 * --------------------------------------------------------------------------
		 * Module Loading Directives
		 * --------------------------------------------------------------------------
		 */
		modules = {
			// An array of modules names to load, empty means all of them
			include : [],
			// An array of modules names to NOT load, empty means none
			exclude : []
		};

		/**
		 * --------------------------------------------------------------------------
		 * Application Logging (https://logbox.ortusbooks.com)
		 * --------------------------------------------------------------------------
		 * By Default we log to the console, but you can add many appenders or destinations to log to.
		 * You can also choose the logging level of the root logger, or even the actual appender.
		 */

		/**
		 * --------------------------------------------------------------------------
		 * Layout Settings
		 * --------------------------------------------------------------------------
		 */
		layoutSettings = { defaultLayout : "manager.cfm", defaultView : "" };

		/**
		 * --------------------------------------------------------------------------
		 * Custom Interception Points
		 * --------------------------------------------------------------------------
		 */
		interceptorSettings = { customInterceptionPoints : [] };

		/**
		 * --------------------------------------------------------------------------
		 * Application Interceptors
		 * --------------------------------------------------------------------------
		 * Remember that the order of declaration is the order they will be registered and fired
		 */
		interceptors = [
			{
				name    = "Main",
				class   = "com.apirone.core.interceptor.MainInterceptor",
				properties = {}
			}
		
		];

		/**
		 * --------------------------------------------------------------------------
		 * Flash Scope Settings
		 * --------------------------------------------------------------------------
		 * The available scopes are : session, client, cluster, ColdBoxCache, or a full instantiation CFC path
		 */
		flash = {
			scope        : "session",
			properties   : {}, // constructor properties for the flash scope implementation
			inflateToRC  : true, // automatically inflate flash data into the RC scope
			inflateToPRC : false, // automatically inflate flash data into the PRC scope
			autoPurge    : true, // automatically purge flash data for you
			autoSave     : true // automatically save flash scopes at end of a request and on relocations.
		};

		/**
		 * --------------------------------------------------------------------------
		 * App Conventions
		 * --------------------------------------------------------------------------
		 */
		conventions = {
			handlersLocation : "controllers",
			viewsLocation    : "views",
			layoutsLocation  : "layouts",
			modelsLocation   : "models",
			eventAction      : "index"
		};

		moduleSettings = {
			cbswagger = {
				// The route prefix to search.  Routes beginning with this prefix will be determined to be api routes
				"routes" : [ "api" ],
				// The default output format: json or yml
				// Routes to exclude by prefix.  Routes beginning with this prefix will be excluded
				"excludeRoutesPrefix" : [ "cbSwagger", "relax" ],
				// Any routes to exclude - may use exact matches or globbing patterns e.g `[ "api/v1/mysecret" ]` or `[ "**/secret", "**/undocumented" ]` (no initial `/`, trailing `/` optional for routes)
				"excludeRoutes"	: [],
				// Routes to exclude based on event
				"excludeEvents" : [],
				"defaultFormat" : "json",
				// A convention route, relative to your app root, where request/response samples are stored ( e.g. resources/apidocs/responses/[module].[handler].[action].[HTTP Status Code].json )
				"samplesPath" : "resources/apidocs",
				// Information about your API
				"info"		:{
					// A title for your API
					"title": "Rest API for ZeroBenefit" ,
					// A description of your API
					"contact":{
						"name": "Zero Benefit IT dep.",
						"email": "info@zerobenefit.it"
					},
					//The version of your API
					"version":"1.0.0",
				},
			
				// Tags
				"tags" : [],
			
				// https://swagger.io/specification/#serverObject
				"servers" : [
					{
						"url" 			: "https://www.zerobenefit.it/api",
						"description" 	: "Production server"
					},
					{
						"url" 			: "https://test.zerobenefit.it/api",
						"description" 	: "Test server"
					}
				],
			
				// An element to hold various schemas for the specification.
				// https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#componentsObject
				"components" : {
			
					// Define your security schemes here
					// https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#securitySchemeObject
					"securitySchemes" : {
						"UserSecurity" : {
							// REQUIRED. The type of the security scheme. Valid values are "apiKey", "http", "oauth2", "openIdConnect".
							"type" 			: "http",
							// A short description for security scheme. CommonMark syntax MAY be used for rich text representation.
							"description" 	: "HTTP Basic auth",
							// REQUIRED. The name of the HTTP Authorization scheme to be used in the Authorization header as defined in RFC7235.
							"scheme" 		: "basic"
						},
						"APIKey" : {
							"type" 			: "apiKey",
							"description" 	: "An API key for security",
							"name" 			: "x-api-key",
							"in" 			: "header"
						}
					}
				},
			
				// A default declaration of Security Requirement Objects to be used across the API.
				// https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#securityRequirementObject
				// Only one of these requirements needs to be satisfied to authorize a request.
				// Individual operations may set their own requirements with `@security`
				"security" : [
					{ "APIKey" : [] },
					{ "UserSecurity" : [] }
				]
			}	
		}
	
	}

	/**
	 * Development environment
	 */
	function development() {
		coldbox.customErrorTemplate = "/coldbox/system/exceptions/BugReport.cfm"; // static bug reports
		//coldbox.customErrorTemplate = "/coldbox/system/exceptions/Whoops.cfm"; // interactive bug report
	}

}
