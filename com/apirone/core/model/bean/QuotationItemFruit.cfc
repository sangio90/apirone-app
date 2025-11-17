component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="position" type="Numeric";
	property name="product" type="com.apirone.core.model.bean.Product";
	property name="items" type="com.apirone.core.model.bean.QuotationItemProductItem[]";

	public QuotationItemFruit function init(){
		return this;
	}

}
