component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="price" type="Numeric";
	property name="quantity" type="Numeric";
	property name="notes" type="String";
	property name="hash" type="String";

	property name="quotation" type="com.apirone.core.model.bean.Quotation";
	property name="quotationZone" type="com.apirone.core.model.bean.QuotationZone";

	property name="items" type="com.apirone.core.model.bean.QuotationItemProductItem[]";
	property name="product" type="com.apirone.core.model.bean.Product";
	property name="image" type="com.apirone.core.model.bean.File";

	public QuotationItem function init(){
		return this;
	}

}
