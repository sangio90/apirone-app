component extends="com.apirone.core.model.bean.Profile" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "shortId", "status", "name"],
		profiles = {
		}
	}

	public BillingProfile function init(){
		return this;
	}
}