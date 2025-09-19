component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = { defaultIncludes = [ "id", "name" ] }

	public com.apirone.core.model.bean.Entity function init(){
		return this;
	}

}
