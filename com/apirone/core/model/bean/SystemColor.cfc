component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = { defaultIncludes = [ "id", "name", "hex" ] }

	property name="class" type="String";
	property name="hex" type="String";

	public SystemColor function init(){
		return this;
	}

}
