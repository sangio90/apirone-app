component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"shortId",
			"firstName",
			"lastName",
			"description"
		],
		profiles = {}
	}

	property name="firstName" type="String";
	property name="lastName" type="String";
	property name="description" type="String";

	public Lead function init(){
		return this;
	}
}