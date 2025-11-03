component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="code" type="String";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="type" type="com.apirone.core.model.bean.ProductCategoryType";
	property name="mode" type="com.apirone.core.model.bean.ProductCategoryMode";

	public ProductCategory function init(){
		return this;
	}

}
