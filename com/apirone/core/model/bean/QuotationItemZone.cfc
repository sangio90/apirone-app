component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="zoneName" type="String";
	property name="quotationItem" type="com.apirone.core.model.bean.QuotationItem";
	property name="parent" type="com.apirone.core.model.bean.QuotationItemZone";

	public QuotationItemZone function init(){
		return this;
	}
}
