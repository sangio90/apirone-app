component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "name" ],
		profiles        = { list = { defaultIncludes = [ "id", "name" ] } }
	}

	property name="status" type="com.apirone.core.model.bean.Status";

	public PriceType function init(){
		return this;
	}

}
