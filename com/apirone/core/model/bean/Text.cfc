component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = { defaultIncludes = [ "id", "name", "kind", "lang" ] }

	property name="lang" type="com.apirone.core.model.bean.Lang";
	property name="status" type="com.apirone.core.model.bean.Status";

	// { "key" = "value" } es. { "attributeId" = "Color" }
	property name="entity" type="com.apirone.core.model.bean.Entity";
	property name="kind" type="com.apirone.core.model.bean.TextKind";

	public Text function init(){
		return this;
	}

}
