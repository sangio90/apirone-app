component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = { defaultIncludes = [ "id", "name", "code" ] }

	public ModelType function init(){
		return this;
	}

}
