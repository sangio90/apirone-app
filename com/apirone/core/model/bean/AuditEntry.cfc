component extends="auditLogger.bean.AuditEntry" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "shortId", "entity", "action", "message" ],
		profiles = {
			list = {
				defaultIncludes = [
					"id",
					"account.id",
					"message",
					"severity",
					"entity",
					"action",
					"ipAddress",
					"createdAt"
				]
			},
			detail = {
				defaultIncludes = [
					"id",
					"account.id",
					"message",
					"severity",
					"entity",
					"action",
					"ipAddress",
					"createdAt",
					"userAgent",
					"payload"
				]
			}
		}
	}

	property name="id" type="String";
	property name="account" type="com.apirone.core.model.bean.Account";

	public AuditEntry function init(){
		return this;
	}

}
