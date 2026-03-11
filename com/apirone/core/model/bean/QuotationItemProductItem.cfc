component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="level" type="Numeric";
	property name="quotationItemId" type="String";
	property name="quotationItemFruitId" type="Numeric";
	property name="productItem" type="com.apirone.core.model.bean.ProductItem";
	property name="origin" type="com.apirone.core.model.bean.ProductItem";
	property name="note" type="String";

	public QuotationItemProductItem function init(){
		return this;
	}

}
