component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = { defaultIncludes = [ "id", "name", "color" ] }

	property name="color" type="com.apirone.core.model.bean.SystemColor";

	public Status function init(){
		return this;
	}

}
