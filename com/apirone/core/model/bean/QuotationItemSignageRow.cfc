component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="textAlign" type="String";
	property name="content" type="String";
	property name="charCount" type="Numeric";
	property name="orderby" type="Numeric";

	property name="quotationItemId" type="String";

	public QuotationItemSignageRow function init(){
		return this;
	}

}
