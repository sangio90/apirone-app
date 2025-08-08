component accessors="true" {

	property name="dao" type="auditLogger.dao.AuditLoggerDAO";

	public Struct function log( required auditLogger.bean.LogEntry logEntry ){
		if ( !IsNull( logEntry.getPayload() ) OR IsStruct( logEntry.getPayload() ) ) {
			var payload = SerializeJSON( logEntry.getPayload() );
			logEntry.setPayload( payload );
		}

		var newId = getDao().insert( logEntry = logEntry );

		return { "id" = newId };
	}

}
