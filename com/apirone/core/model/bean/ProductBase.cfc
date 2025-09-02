component extends="com.apirone.core.model.bean.Product" accessors="true" {

	property name="code" type="String";
	property name="positionCount" type="Numeric";
	property name="lines" type="com.apirone.core.model.bean.Line[]";
	property name="category" type="com.apirone.core.model.bean.ProductCategory";

	public ProductBase function init(){
		return this;
	}

}
