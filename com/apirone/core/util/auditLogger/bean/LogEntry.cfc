component accessors="true" {

	property name="message" type="string";
	property name="action" type="string";
	property name="entity" type="string";
	property name="severity" type="string";
	property name="accountId" type="string";
	property name="createdAt" type="date";
	property name="ipAddress" type="string";
	property name="userAgent" type="string";
	property name="payload" type="Any";

	public LogEntry function init(){
		return this;
	}

}
