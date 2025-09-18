/**
 * AuditHelper.cfc
 * Helper per audit logging condiviso
 * @author Roberto Marzialetti <roberto@marzialetti.com>
 * @since 14/08/2025a
 */

component extends="com.apirone.core.util.helper.AbsHelper" {

	public Struct function logEvent(
		required String event,
		required String message,
		Any payload,
		String severity = "INFO",
		String accountId,
		Boolean allowAnonymous = false
	){
		var logger = getContainer().getInstance( "AuditLogger" );

		// TODO: better than this

		var accountId = getCurrentAccountId( accountId, allowAnonymous );

		var result = logger.log(
			event     = arguments.event,
			message   = arguments.message,
			accountId = accountId,
			payload   = payload,
			severity  = severity,
			ipAddress = getRealIP(),
			userAgent = CGI.http_user_agent
		)

		return logger;
	}

	// Recupera l'ID utente o fallback
	private any function getCurrentAccountId( String accountId = "", boolean allowAnonymous = false ){
		if ( !IsNull( arguments.accountId ) && Len( arguments.accountId ) ) {
			return arguments.accountId;
		}

		if ( StructKeyExists( session, "user" ) && !IsNull( session.user.getAccount() ) ) {
			return session.user.getAccount().getId();
		}

		if ( arguments.allowAnonymous ) {
			return "e702bf0b-d047-4ed7-bd64-5975efab123a"; // utente di servizio
		}

		//return "e702bf0b-d047-4ed7-bd64-5975efab123a";

		Throw( message = "Account not authenticated and anonymous not allowed" );
	}

	private function getRealIP(){

        var headers = GetHTTPRequestData().headers;

        if ( StructKeyExists( headers, "x-cluster-client-ip" ) ) {
			return headers[ "x-cluster-client-ip" ];
		}
		if ( StructKeyExists( headers, "X-Forwarded-For" ) ) {
			return headers[ "X-Forwarded-For" ];
		}

		return Len( CGI.REMOTE_ADDR ) ? Trim( listFirst( CGI.REMOTE_ADDR ) ) : "999.999.999.999";

    }

}

