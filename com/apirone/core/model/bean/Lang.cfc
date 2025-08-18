component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "name", "kind", "lang", "status" ]
	}

	public Lang function init(){
		return this;
	}

}
