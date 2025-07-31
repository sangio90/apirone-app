component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="price" type="Numeric";
	property name="quantity" type="Numeric";

	property name="quotation" type="com.apirone.core.model.bean.Quotation";

	public QuotationItem function init(){
		return this;
	}

}
