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
			},
			tree = {
				defaultIncludes = [
					"id",
					"shortId",
					"status",
					"origin.id",
					"level",
					"attribute",
					"attributeValue.rawValue",
					"componentCount"
				]
			},
			treelight = {
				defaultIncludes = [
					"id",
					"shortId",
					"origin.id",
					"attribute.id",
					"attribute.name",
					"attributeValue.id",
					"attributeValue.rawValue.name"
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
	
	property name="prices" type="com.apirone.core.model.bean.Price[]" default=[];

	public ProductItem function init(){
		setChildren( [] );

		return this;
	}

	public Struct function getPrice( required String typeId ){
		for ( var price in getPrices() ) {
			if ( price.getType().getId() EQ typeId ) {
				return price;
			}
		}
	}

}
