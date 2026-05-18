component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="quantity" type="Numeric";
	property name="ordinamento" type="Numeric";
	property name="note" type="String";
	property name="hash" type="String";
	property name="special" type="Boolean" default="false";
	property name="hash" type="String";
	property name="customImage" type="Boolean" default="false";

	property name="quotation" type="com.apirone.core.model.bean.Quotation";
	property name="quotationZone" type="com.apirone.core.model.bean.QuotationZone";
	property name="position" type="com.apirone.core.model.bean.QuotationZonePosition";
	property name="price" type="com.apirone.core.model.bean.QuotationItemPrice";
	property name="status" type="com.apirone.core.model.bean.Status";

	property name="items" type="com.apirone.core.model.bean.QuotationItemProductItem[]";
	property name="positions" type="com.apirone.core.model.bean.QuotationItemPosition[]";
	property name="product" type="com.apirone.core.model.bean.Product";
	property name="article" type="com.apirone.core.model.bean.Article";
	property name="image" type="com.apirone.core.model.bean.File";

	public QuotationItem function init(){
		return this;
	}

}
