component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "productCategory", "line", "markupValue" ]
	};

	property name="markupValue" type="Numeric";
	property name="category" type="com.apirone.core.model.bean.ProductCategory";
	property name="line" type="com.apirone.core.model.bean.Line";

	public ProductCategory function init(){
		return this;
	}

}
