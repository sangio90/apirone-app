component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"shortId",
			"name",
			"code",
			"category",
			"categories"
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
					"lines"
				]
			}
		}
	}

	/*
		complex (plates)
	*/
	property name="model" type="com.apirone.core.model.bean.Model"; //bundle
	property name="line" type="com.apirone.core.model.bean.Line"; //bundle
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
	property name="category" type="com.apirone.core.model.bean.ProductCategory"; //bundle

	public Product function init(){
		return this;
	}

}
