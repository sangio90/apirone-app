component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {
	
	property name="lang" type="com.apirone.core.model.bean.Lang";
	property name="status" type="com.apirone.core.model.bean.Status";

	//{ "key" = "value" } 
	//es. { "attributeId" = "Color" }
	property name="entity" type="com.apirone.core.model.bean.Entity";

	public Text function init(){

		return this;

	}

}
