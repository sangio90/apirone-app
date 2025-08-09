component accessors="true" {

	property name="dao" type="auditLogger.dao.AuditLoggerDAO";

	public Struct function log( required auditLogger.bean.AuditEntry auditEntry ){
		var newId = getDao().insert( auditEntry = auditEntry );

		return { "id" = newId };
	}

}
