component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {
	property name="textAlign" type="String";
	property name="content" type="String";
	property name="chatCount" type="Numeric";
	property name="orderby" type="Numeric";

	property name="quotationItem" type="com.apirone.core.model.bean.QuotationItemSignage";

	public QuotationItemSignageRow function init(){
		return this;
	}

}
