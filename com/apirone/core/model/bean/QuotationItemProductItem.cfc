component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"shortId",
			"productItem.id",
			"productItem.orderby",
			"productItem.level",
			"productItem.attribute",
			"productItem.attributeValue.rawValue",
			"origin",
			"origin.attribute",
			"level"
		]
	}

	property name="level" type="Numeric";
	property name="quotationItemId" type="String";
	property name="productItem" type="com.apirone.core.model.bean.ProductItem";
	property name="origin" type="com.apirone.core.model.bean.ProductItem";

	public QuotationItemProductItem function init(){
		return this;
	}

}
