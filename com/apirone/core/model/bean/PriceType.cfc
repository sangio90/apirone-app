component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="status" type="com.apirone.core.model.bean.Status";
	property name="methods" type="com.apirone.core.model.bean.PriceMethod[]";
	property name="entities" type="com.apirone.core.model.bean.Entity[]";

	public PriceType function init(){
		return this;
	}

}
