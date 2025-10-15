component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"shortId",
			"name",
			"orderby",
			"status"
		]
	}

	property name="orderby" type="Numeric";
	property name="status" type="com.apirone.core.model.bean.Status";

	public ProductCategoryType function init(){
		return this;
	}

}
