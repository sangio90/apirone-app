component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="quotationItem" type="com.apirone.core.model.bean.QuotationItem";
	property name="productItem" type="com.apirone.core.model.bean.ProductItem";
	property name="origin" type="com.apirone.core.model.bean.QuotationItemProductItem";

	public QuotationItemProductItem function init(){
		return this;
	}

}
