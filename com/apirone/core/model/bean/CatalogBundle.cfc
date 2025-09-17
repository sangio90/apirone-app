component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"shortId",
			"line",
			"model",
			"category",
			"createdAt",
			"markupValue"
		],
		profiles = {
			list = {
				defaultIncludes = [
					"id",
					"shortId",
					"line",
					"model",
					"category",
					"createdAt",
					"markupValue"
				]
			}
		}
	}

	property name="markupValue" type="Numeric" default="0";
	property name="line" type="com.apirone.core.model.bean.Line";
	property name="model" type="com.apirone.core.model.bean.Model";
	property name="category" type="com.apirone.core.model.bean.ProductCategory";

	public CatalogBundle function init(){
		return this;
	}

}
