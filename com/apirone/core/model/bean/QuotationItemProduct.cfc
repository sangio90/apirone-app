component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="quotationItem" type="com.apirone.core.model.bean.QuotationItem";
	property name="product" type="com.apirone.core.model.bean.Product";
	property name="origin" type="com.apirone.core.model.bean.QuotationItemProduct";

	public QuotationItemProduct function init(){
		return this;
	}

}
