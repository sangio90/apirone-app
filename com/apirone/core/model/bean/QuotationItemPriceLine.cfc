component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="amount" type="Numeric";
	property name="quotationItemPriceId" type="Numeric";

	public QuotationItemPriceLine function init(){
		return this;
	}

}
