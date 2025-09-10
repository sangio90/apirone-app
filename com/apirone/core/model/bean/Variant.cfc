component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = { defaultIncludes = [ "id", "name" ] }

	property name="colors" type="com.apirone.core.model.bean.Color[]";

	public Variant function init(){
		return this;
	}

}
