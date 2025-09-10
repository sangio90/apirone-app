component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="price" type="Numeric";
	property name="quantity" type="Numeric";

	property name="quotation" type="com.apirone.core.model.bean.Quotation";
	property name="quotationZone" type="com.apirone.core.model.bean.QuotationZone";
	
	public QuotationItem function init(){
		return this;
	}

}
