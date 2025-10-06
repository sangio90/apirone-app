component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "name", "methods", "status"  ],
		profiles        = { list = { defaultIncludes = [ "id", "name", "methods", "status", "entities", "createdAt" ] } }
	}

	property name="status" type="com.apirone.core.model.bean.Status";
	property name="methods" type="com.apirone.core.model.bean.PriceMethod[]";
	property name="entities" type="com.apirone.core.model.bean.Entity[]";

	public PriceType function init(){
		return this;
	}

}
