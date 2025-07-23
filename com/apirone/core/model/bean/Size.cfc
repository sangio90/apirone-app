component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="fruitsCount" type="Numeric";
	property name="code" type="String";
	property name="type" type="com.apirone.core.model.bean.SizeType";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="categories" type="com.apirone.core.model.bean.ProductCategory[]";

	public Size function init(){
		return this;
	}

}
