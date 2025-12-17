component accessors="true" {

	property name="datasource" type="String";
	property name="config" type="Struct";
	property name="service" type="auditLogger.service.AuditLoggerService";

	public function init( required string datasource, required Struct config ){
		this.setConfig( arguments.config )
		this.setDatasource( arguments.datasource )

		this.factory();

		return this;
	}

	public Struct function log(
		required String event,
		required String message,
		required String userId,
		Any payload,
		String severity  = "INFO",
		String ipAddress = "",
		String userAgent = ""
	){
		arguments.message = Trim( arguments.message );

		var result = parseEvent( arguments.event );

		var thisPayload = NullValue();

		if ( !Len( arguments.ipAddress ) ) ipAddress = cgi.remote_addr;
		if ( !Len( arguments.userAgent ) ) userAgent = cgi.http_user_agent;

		if ( !IsNull( arguments.payload ) AND IsStruct( arguments.payload ) ) {
			if ( !hasUppercaseOnlyKey( arguments.payload ) ) {
				thisPayload = SerializeJSON( arguments.payload );
			}
		} else {
			if ( Len( arguments.payload ) ) {
				// Plain variable, but I need JSONB for db
				thisPayload = SerializeJSON( { "description" = arguments.payload } );
			}
		}

		var bean = new AuditLogger.bean.AuditEntry();

		bean.setMessage( arguments.message );
		bean.setAction( result.action );
		bean.setEntity( result.entity );
		bean.setSeverity( arguments.severity );
		bean.setUserId( arguments.userId );
		bean.setCreatedAt( Now() );
		bean.setIpAddress( arguments.ipAddress );
		bean.setUserAgent( arguments.userAgent );
		bean.setPayload( thisPayload );

		return getService().log( bean );
	}


	/*
		private methods
	*/

	private Boolean function hasUppercaseOnlyKey( required struct payload ){
		for ( var key in payload ) {
			if ( key === UCase( key ) ) {
				Throw(
					type    = "AuditLogger.errors.invalidPayloadKey",
					message = "Invalid key [#key#] format. Use lowercase format and double quotes for setting variable. E.g. ['myKey']."
				)
			}
		}

		return false;
	}

	private Struct function parseEvent( required string event ){
		var parts = ListToArray( arguments.event, "." );

		if ( ArrayLen( parts ) != 2 ) {
			Throw(
				type    = "AuditLogger.errors.invalidEventFormat",
				message = "Invalid event format. Use 'ENTITY.EVENT' (e.g. PRODUCT.CREATED)."
			);
		}

		var entity = UCase( parts[ 1 ] );
		var action = UCase( parts[ 2 ] );

		if ( !StructKeyExists( getConfig().entities, entity ) ) {
			Throw( type = "AuditLogger.errors.unknownEntity", message = "Unknown entity: [#entity#]" );
		}

		if ( !StructKeyExists( getConfig().actions, action ) ) {
			Throw(
				type    = "AuditLogger.errors.unknownAction",
				message = "Unknown action: [#action#] for entity [#entity#]"
			);
		}

		return { entity = entity, action = action };
	}

	private Void function factory(){
		var dao     = new auditLogger.dao.AuditLoggerDAO();
		var service = new auditLogger.service.AuditLoggerService();

		dao.setDatasource( getDatasource() );

		service.setDAO( dao );

		this.setService( service );
	}

}
