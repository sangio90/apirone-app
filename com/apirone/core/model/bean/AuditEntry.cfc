component extends="auditLogger.bean.AuditEntry" accessors="true" {

	property name="id" type="String";
	property name="user" type="com.apirone.core.model.bean.User";

	public AuditEntry function init(){
		return this;
	}

}
