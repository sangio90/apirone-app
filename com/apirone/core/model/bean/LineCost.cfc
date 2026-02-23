component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="cost" type="String";
	property name="line" type="com.apirone.core.model.bean.Line";
	property name="finish" type="com.apirone.core.model.bean.Finish";
	property name="category" type="com.apirone.core.model.bean.ProductCategory";

	public LineCost function init(){
		return this;
	}

}
