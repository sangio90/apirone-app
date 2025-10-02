component accessors="true" {

	property name="baseUrl" type="string";
	property name="apiKey" type="string";
	property name="authToken" type="string";
	property name="defaultHeaders" type="struct";
	property name="timeout" type="numeric" default=30;

	/**
	 * Inizializza il servizio con URL base, chiave API e token auth
	 */
	public AbsRestApi function init(
		required string baseUrl,
		string apiKey         = "",
		string authToken      = "",
		struct defaultHeaders = {}
	){
		setBaseUrl( baseUrl );
		setApiKey( apiKey );
		setAuthToken( authToken );
		setDefaultHeaders( defaultHeaders );

		return this;
	}

	/**
	 * Metodo generico per chiamare API REST
	 */
	public struct function call(
		required string method,
		required string endpoint,
		any data       = "",
		struct headers = {},
		struct params  = {}
	){
		var apiUrl = getBaseUrl() & endpoint;

		// Aggiungi authToken se presente
		if ( Len( getAuthToken() ) ) {
			if ( Find( "?", apiUrl ) ) {
				apiUrl &= "&token=" & UrlEncodedFormat( getAuthToken() );
			} else {
				apiUrl &= "?token=" & UrlEncodedFormat( getAuthToken() );
			}
		}

		// Aggiungi params alla URL se GET
		if ( method == "GET" && !StructIsEmpty( params ) ) {
			if ( Find( "?", apiUrl ) ) {
				apiUrl &= "&" & buildQueryString( params );
			} else {
				apiUrl &= "?" & buildQueryString( params );
			}
		}

		// Prepara headers
		var requestHeaders = Duplicate( getDefaultHeaders() );
		StructAppend( requestHeaders, headers, true );

		// Aggiungi auth se apiKey presente
		if ( Len( getApiKey() ) ) {
			requestHeaders[ "Authorization" ] = "Bearer " & getApiKey();
		}

		// Prepara body per metodi non GET
		var body = "";
		if ( method != "GET" && !IsSimpleValue( data ) ) {
			body                             = SerializeJSON( data );
			requestHeaders[ "Content-Type" ] = "application/json";
		} else if ( IsSimpleValue( data ) ) {
			body = data;
		}

		// Log richiesta
		WriteLog(
			type = "information",
			text = "API Request: #method# #apiUrl# | Headers: #SerializeJSON( requestHeaders )# | Body: #Left( body, 500 )#"
		);

		// Fai la chiamata
		cfhttp(
			url     = apiUrl,
			method  = method,
			timeout = getTimeout()
		) {
			for ( var key in requestHeaders ) {
				cfhttpparam(
					type  = "header",
					name  = key,
					value = requestHeaders[ key ]
				);
			}
			if ( Len( body ) ) {
				cfhttpparam( type = "body", value = body );
			}
		}

		// Gestisci risposta
		var response = {
			statusCode = cfhttp.statusCode,
			headers    = cfhttp.responseHeader,
			body       = cfhttp.fileContent
		};

		// Log risposta
		WriteLog(
			type = "information",
			text = "API Response: #response.statusCode# | Headers: #SerializeJSON( response.headers )# | Body: #Left( response.body, 500 )#"
		);

		// Deserializza JSON se applicabile
		if ( Find( "application/json", response.headers[ "Content-Type" ] ?: "" ) ) {
			try {
				response.data = DeserializeJSON( response.body );
			} catch ( any e ) {
				response.data = response.body;
			}
		} else {
			response.data = response.body;
		}

		// Lancia errore se status non 2xx
		if ( Left( response.statusCode, 1 ) != "2" ) {
			WriteLog( type = "error", text = "API Error: #response.statusCode# - #response.body#" );
			Throw( type = "RestApiError", message = "API call failed: #response.statusCode# - #response.body#" );
		}

		return response;
	}

	/**
	 * Helper per GET
	 */
	public any function get(
		required string endpoint,
		struct params  = {},
		struct headers = {}
	){
		var response = call( "GET", endpoint, "", headers, params );
		return response.data;
	}

	/**
	 * Helper per POST
	 */
	public any function post(
		required string endpoint,
		any data       = "",
		struct headers = {}
	){
		var response = call( "POST", endpoint, data, headers );
		return response.data;
	}

	/**
	 * Helper per PUT
	 */
	public any function put(
		required string endpoint,
		any data       = "",
		struct headers = {}
	){
		var response = call( "PUT", endpoint, data, headers );
		return response.data;
	}

	/**
	 * Helper per DELETE
	 */
	public any function delete( required string endpoint, struct headers = {} ){
		var response = call( "DELETE", endpoint, "", headers );
		return response.data;
	}

	/**
	 * Helper per PATCH
	 */
	public any function patch(
		required string endpoint,
		any data       = "",
		struct headers = {}
	){
		var response = call( "PATCH", endpoint, data, headers );
		return response.data;
	}

	/**
	 * Costruisce query string da struct
	 */
	private string function buildQueryString( required struct params ){
		var pairs = [];
		for ( var key in params ) {
			pairs.append( UrlEncodedFormat( key ) & "=" & UrlEncodedFormat( params[ key ] ) );
		}
		return ArrayToList( pairs, "&" );
	}

}
