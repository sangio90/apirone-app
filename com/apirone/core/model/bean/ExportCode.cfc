component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="category" type="com.apirone.core.model.bean.ProductCategory";
	property name="line" type="com.apirone.core.model.bean.Line";
	property name="model" type="com.apirone.core.model.bean.Model";
	property name="finish" type="com.apirone.core.model.bean.Finish";
	property name="product" type="com.apirone.core.model.bean.Product";

	public ExportCode function init(){
		return this;
	}

}
