component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="model" type="com.apirone.core.model.bean.Model";
	property name="productCategory" type="com.apirone.core.model.bean.ProductCategory";
	property name="line" type="com.apirone.core.model.bean.Line";
	property name="width" type="Numeric";
	property name="height" type="Numeric";
	property name="length" type="Numeric";

	public ModelConfig function init(){
		return this;
	}

}
