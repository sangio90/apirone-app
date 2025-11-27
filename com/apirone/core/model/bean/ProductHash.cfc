component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"hash",
			"jsonData"
		]
	}

	property name="hash" type="String";
	property name="jsonData" type="String";

	public ProductHash function init(){
		return this;
	}

}
