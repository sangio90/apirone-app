component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"frameCellId",
			"frameId",
			"row",
			"col",
			"value"
		]
	};

	property name="row" type="Numeric" default=0;
	property name="col" type="Numeric" default=0;
	property name="value" type="String" default="";
	property name="frameId" type="String";

	public Frame function init(){
		return this;
	}

}
