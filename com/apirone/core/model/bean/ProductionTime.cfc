component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "name" ],
		profiles        = {
			detail = { defaultIncludes = [ "id", "name", "code", "status" ] }
		}
	}

	property name="status" type="com.apirone.core.model.bean.Status";

	public ProductionTime function init(){
		return this;
	}

}
