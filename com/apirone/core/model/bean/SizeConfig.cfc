component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="size" type="com.apirone.core.model.bean.Size";
	property name="productCategory" type="com.apirone.core.model.bean.ProductCategory";
	property name="line" type="com.apirone.core.model.bean.Line";
	property name="width" type="Numeric";
	property name="height" type="Numeric";

	public SizeConfig function init(){
		return this;
	}

}
