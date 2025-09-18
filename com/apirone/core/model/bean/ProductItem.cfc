component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "shortId", "name", "code" ],
		profiles        = {
			list = {
				defaultIncludes = [
					"id",
					"status",
					"origin",
					"attribute",
					"attributeValue",
					"nameItem",
					"componentCount",
					"level",
					"orderBy",
					"productId",
					"spaces"
				]
			}
		}
	}

	property name="level" type="Numeric";
	property name="orderBy" type="String";
	property name="productId" type="String";

	property name="status" type="com.apirone.core.model.bean.Status";
	property name="origin" type="com.apirone.core.model.bean.ProductItem";
	property name="attributeValue" type="com.apirone.core.model.bean.AttributeValue";
	property name="attribute" type="com.apirone.core.model.bean.Attribute";

	property name="children" type="com.apirone.core.model.bean.ProductItem[]";

	property name="componentCount" type="Numeric" default=0;

	public ProductItem function init(){
		setChildren( [] );

		return this;
	}

}
