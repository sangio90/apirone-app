component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="quotationItem" type="com.apirone.core.model.bean.QuotationItem";
	property name="parent" type="com.apirone.core.model.bean.QuotationItemZone";

	public QuotationItemZone function init(){
		return this;
	}
}
