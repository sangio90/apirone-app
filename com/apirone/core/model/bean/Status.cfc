component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = { defaultIncludes = [ "id", "name" ] }

	property name="color" type="com.apirone.core.model.bean.SystemColor";

	public Status function init(){
		return this;
	}

}
