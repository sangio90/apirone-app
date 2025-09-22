component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "productCategory", "line", "markupValue" ]
	};

	property name="markup" type="Numeric";
	property name="ProductCategory" type="com.apirone.core.model.bean.ProductCategory";
	property name="line" type="com.apirone.core.model.bean.Line";

	public ProductCategoryLine function init(){
		return this;
	}

}
