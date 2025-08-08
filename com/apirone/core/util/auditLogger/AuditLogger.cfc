component accessors="true" {

	property name="datasource" type="String";
	property name="x" type="String";
	property name="actions" type="Struct";
	property name="service" type="auditLogger.service.AuditLoggerService";

	public function init( required string datasource, required Struct actions ){
		this.setActions( arguments.actions )
		this.setDatasource( arguments.datasource )

		this.factory();

		return this;
	}

	public Struct function log(
		required string action,
		required string message,
		required string accountId,
		Any payload,
		String severity  = "INFO",
		String ipAddress = "",
		String userAgent = ""
	){
		arguments.message = Trim( arguments.message );

		var result = parseAction( arguments.action );

		if ( !Len( arguments.ipAddress ) ) ipAddress = CGI.remote_addr;
		if ( !Len( arguments.userAgent ) ) userAgent = CGI.http_user_agent;

		var bean = new AuditLogger.bean.LogEntry();

		bean.setMessage( arguments.message );
		bean.setAction( result.action );
		bean.setEntity( result.entity );
		bean.setSeverity( arguments.severity );
		bean.setAccountId( arguments.accountId );
		bean.setCreatedAt( Now() );
		bean.setIpAddress( arguments.ipAddress );
		bean.setUserAgent( arguments.userAgent );
		bean.setPayload( arguments.payload );

		return getService().log( bean );
	}


	/*
		private methods
	*/

	private Struct function parseAction( required string action ){
		var parts = ListToArray( arguments.action, "." );

		if ( ArrayLen( parts ) != 2 ) {
			Throw(
				type    = "LoggerAudit.errors.invalidActionFormat",
				message = "Invalid action format. Use 'ENTITY.ACTION' (e.g. PRODUCT.CREATED)."
			);
		}

		var entity = UCase( parts[ 1 ] );
		var action = UCase( parts[ 2 ] );

		if ( !StructKeyExists( getActions(), entity ) ) {
			Throw( type = "LoggerAudit.errors.unknownEntity", message = "Unknown entity: [#entity#]" );
		}

		if ( !StructKeyExists( getActions()[ entity ], action ) ) {
			Throw(
				type    = "LoggerAudit.errors.invalidAction",
				message = "Invalid action [#action#] for entity [#entity#]"
			);
		}

		return { entity = entity, action = action };
	}

	private Boolean function isValid( required string action ){
		try {
			parseAction( arguments.actionString );
			return true;
		} catch ( any e ) {
			return false;
		}
	}

	private Void function factory(){
		var dao     = new auditLogger.dao.AuditLoggerDAO();
		var service = new auditLogger.service.AuditLoggerService();

		dao.setDatasource( getDatasource() );

		service.setDAO( dao );

		this.setService( service );
	}

}
