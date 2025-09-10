component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = { defaultIncludes = [ "id", "name" ] }

	public Color function init(){
		return this;
	}

}
