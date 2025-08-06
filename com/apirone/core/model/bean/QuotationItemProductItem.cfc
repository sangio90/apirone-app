component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="quotationItemProduct" type="com.apirone.core.model.bean.QuotationItemProduct";
	property name="productItem" type="com.apirone.core.model.bean.ProductItem";
	property name="parent" type="com.apirone.core.model.bean.QuotationItemProductItem";

	public QuotationItemProductItem function init(){
		return this;
	}

}
