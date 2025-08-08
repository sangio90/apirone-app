component extends="auditLogger.bean.AuditEntry" accessors="true" {

	property name="account" type="com.apirone.core.model.bean.Account";

	public AuditEntry function init(){
		return this;
	}

}
