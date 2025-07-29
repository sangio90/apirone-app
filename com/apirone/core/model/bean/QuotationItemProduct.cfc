component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="quotationItem" type="com.apirone.core.model.bean.QuotationItem";
	property name="product" type="com.apirone.core.model.bean.Product";
	property name="parent" type="com.apirone.core.model.bean.QuotationItemProduct";

	public QuotationItemProduct function init(){
		return this;
	}
}