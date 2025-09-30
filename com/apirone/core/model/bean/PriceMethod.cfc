component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = { defaultIncludes = [ "id", "name", "simbol" ] }

	property name="simbol" type="String";

	public PriceMethod function init(){
		return this;
	}

}
