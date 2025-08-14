/**
 * AbsDecorator class
 * @author Roberto Marzialetti <roberto@marzialetti.com>
 * @since 09/08/2025
 */

component output="false" accessors="true" {

	/*
	public any function invoke( required string methodName, required struct arguments ){
		var result = Invoke( this.wrappedService, methodName, arguments );
		return result;
	}
	*/

	private Struct function logEvent(){
		getAuditHelper().logEvent( argumentCollection = arguments );
	}

	/*
	private Struct function logEvent(
		required String event,
		required String message,
		Any payload,
		String severity = "INFO"
	){
		var logger = getContainer().getInstance( "AuditLogger" );

		// TODO: better than this
		// var accountId = !IsNull( session.user.getAccount().getId() ) ? session.user.getAccount().getId() : "";
		var accountId = session.user.getAccount().getId();

		var result = logger.log(
			event     = arguments.event,
			message   = arguments.message,
			accountId = accountId,
			payload   = payload,
			severity  = severity,
			ipAddress = CGI.remote_addr,
			userAgent = CGI.http_user_agent
		)

		return logger;
	}
	*/

	private Struct function getAuditHelper(){
		var bean = getContainer().getInstance( "AuditHelper" );

		return bean;
	}

	private Struct function getLogger(){
		var bean = getContainer().getInstance( "Logger" );

		return bean;
	}

	private Struct function getContainer(){
		return server[ "wireBox-apirone" ];
	}

}
