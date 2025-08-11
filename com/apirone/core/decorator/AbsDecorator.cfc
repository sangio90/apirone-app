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

	private Struct function logAudit(
		required String type,
		required String message,
		Any payload,
		String severity = "INFO"
	){
		var logger = getModel().getInstance( "AuditLogger" );

		// TODO: better than this
		// var accountId = !IsNull( session.user.getAccount().getId() ) ? session.user.getAccount().getId() : "";
		var accountId = session.user.getAccount().getId();

		var result = logger.log(
			action    = arguments.type,
			message   = arguments.message,
			accountId = accountId,
			payload   = payload,
			severity  = severity,
			ipAddress = CGI.remote_addr,
			userAgent = CGI.http_user_agent
		)

		return logger;
	}

	private Struct function getAudit( required String service ){
		var bean = getModel().getInstance( "AuditLogger" );

		return bean;
	}

	private Struct function getLogger(){
		var bean = getModel().getInstance( "Logger" );

		return bean;
	}

	private Struct function getModel(){
		return server[ "wireBox-apirone" ];
	}

}
