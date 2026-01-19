component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="key" type="String";
	property name="code" type="String";
	property name="description" type="String";
	property name="exportDate" type="Date";
	property name="um" type="String";
	property name="variant" type="String";
	property name="color" type="String";
	property name="note" type="String";
	property name="status" type="String";

	public QuotationItemExported function init(){
		return this;
	}
}
