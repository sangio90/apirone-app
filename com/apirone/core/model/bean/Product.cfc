component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"shortId",
			"name",
			"code",
			"category",
			"categories",
			"line",
			"model",
			"finish"
		],
		mappers  = {},
		profiles = {
			list = {
				defaultIncludes = [
					"id",
					"shortId",
					"name",
					"code",
					"nameItem",
					"status",
					"positionCount",
					"createdAt",
					"code",
					"categories",
					"category",
					"lines",
					"line",
					"model",
					"finish"
				]
			}
		}
	}

	/*
		complex (plates)
		TODO da cancellare line/model sostituite da bundle
		TODO: move to bundle:
			  - remove properties
			  - and shortcut getMolde(), setModel()
	*/
	property name="model" type="com.apirone.core.model.bean.Model";
	property name="line" type="com.apirone.core.model.bean.Line";
	property name="finish" type="com.apirone.core.model.bean.Finish";
	property name="status" type="com.apirone.core.model.bean.Status";

	/*
		simple (fruit)
	*/
	property name="code" type="String";
	property name="positionCount" type="Numeric";
	property name="lines" type="com.apirone.core.model.bean.Line[]";

	/*
		common fields
	*/
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="category" type="com.apirone.core.model.bean.ProductCategory";

	property name="catalogBundle" type="com.apirone.core.model.bean.CatalogBundle";

	public Product function init(){
		return this;
	}

}
