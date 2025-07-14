component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	/*
		plates
	*/
	property name="size" type="com.apirone.core.model.bean.Size";
	property name="line" type="com.apirone.core.model.bean.Line";
	property name="finish" type="com.apirone.core.model.bean.Finish";
	property name="status" type="com.apirone.core.model.bean.Status";

	/*
		fruit
	*/
	property name="code" type="String";
	property name="positionCount" type="Numeric";

	property name="status" type="com.apirone.core.model.bean.Status";
	property name="category" type="com.apirone.core.model.bean.ProductCategory";

	public Product function init(){
		return this;
	}

}
