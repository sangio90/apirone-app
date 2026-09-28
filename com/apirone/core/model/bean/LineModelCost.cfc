component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="cost" type="String";
	property name="line" type="com.apirone.core.model.bean.Line";
	property name="model" type="com.apirone.core.model.bean.Model";
	property name="category" type="com.apirone.core.model.bean.ProductCategory";

	public LineModelCost function init(){
		return this;
	}

}
