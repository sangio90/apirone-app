component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"shortId",
			"name",
			"description"
		],
		profiles = {}
	}

	property name="name" type="String";
	property name="description" type="String";

	public Opportunity function init(){
		return this;
	}
}