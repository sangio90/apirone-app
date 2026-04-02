component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="quotationItemId" type="String";
	property name="position" type="Numeric"; //TODO: to remove
	property name="positions" type="Array"; //["ID0001","ID0002"]
	property name="note" type="String";

	property name="fruit" type="com.apirone.core.model.bean.Product";
	property name="items" type="com.apirone.core.model.bean.QuotationItemProductItem[]";
	property name="file" type="com.apirone.core.model.bean.File[]";

	public QuotationItemFruit function init(){
		return this;
	}

}
