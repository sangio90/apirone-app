component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="quotation" type="com.apirone.core.model.bean.Quotation";
	property name="zone" type="com.apirone.core.model.bean.QuotationItemZone";
	property name="position" type="com.apirone.core.model.bean.QuotationItemPosition";
	property name="product" type="com.apirone.core.model.bean.QuotationItemProduct";
	property name="price" type="Numeric";
	property name="quantity" type="Numeric";

	public QuotationItem function init(){
		return this;
	}
}
