/**
 * IP reale del client.
 *
 * Gli header di forwarding (X-Forwarded-For) sono considerati SOLO se la connessione arriva
 * da un proxy fidato (il nostro nginx): altrimenti chiunque potrebbe falsificarli con un
 * semplice header e scegliersi l'IP (aggirando whitelist, rate limit e audit log).
 *
 * In X-Forwarded-For ogni proxy appende in coda l'IP da cui ha ricevuto la richiesta: la parte
 * a sinistra la scrive il client e non è affidabile. Si legge quindi da destra e si prende il
 * primo IP che non è un proxy fidato.
 *
 * Proxy fidati: proprietà di sistema "security.trustedProxies" (lista per IsIPInRange:
 * wildcard e range a-b), default loopback + reti private.
 */
component output="false" {

	variables.DEFAULT_TRUSTED_PROXIES = "127.0.0.1,::1,10.*.*.*,172.16.0.0-172.31.255.255,192.168.*.*";
	variables.UNKNOWN_IP              = "999.999.999.999";

	public String function get(){
		var remoteAddr = Trim( ListFirst( CGI.REMOTE_ADDR ) );

		if ( !Len( remoteAddr ) ) return variables.UNKNOWN_IP;
		if ( !isTrusted( remoteAddr ) ) return remoteAddr;

		var headers = GetHTTPRequestData( false ).headers;
		var hops    = StructKeyExists( headers, "X-Forwarded-For" ) ? ListToArray( headers[ "X-Forwarded-For" ], "," ) : [];

		for ( var i = ArrayLen( hops ); i >= 1; i-- ) {
			var hop = Trim( hops[ i ] );
			if ( Len( hop ) && !isTrusted( hop ) ) return sanitize( hop );
		}

		// Tutta la catena è interna (es. client in LAN): vale il primo hop, se c'è
		return ArrayLen( hops ) ? sanitize( Trim( hops[ 1 ] ) ) : remoteAddr;
	}

	private Boolean function isTrusted( required String ip ){
		try {
			return IsIPInRange( getTrustedProxies(), arguments.ip );
		} catch ( any e ) {
			// valore non parsabile come IP: di certo non è un nostro proxy
			return false;
		}
	}

	private String function getTrustedProxies(){
		var value = CreateObject( "java", "java.lang.System" ).getProperty( "security.trustedProxies" );
		return ( !IsNull( value ) && Len( Trim( value ) ) ) ? Trim( value ) : variables.DEFAULT_TRUSTED_PROXIES;
	}

	// audit_logs.ip_address è VARCHAR(45)
	private String function sanitize( required String ip ){
		return Left( arguments.ip, 45 );
	}

}
