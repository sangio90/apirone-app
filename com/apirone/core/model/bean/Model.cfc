component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "shortId", "name", "code" ],
		defaultExcludes = [],
		neverInclude    = [],
		defaults        = {},
		mappers         = {},
		profiles        = {
			list = {
				defaultIncludes = [
					"id",
					"shortId",
					"name",
					"fruitsCount",
					"nameItem",
					"status",
					"nameItem",
					"descriptionItem",
					"createdAt",
					"code",
					"categories"
				]
			}
		}
	}

	property name="fruitsCount" type="Numeric";
	property name="code" type="String";
	property name="type" type="com.apirone.core.model.bean.ModelType";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="categories" type="com.apirone.core.model.bean.ProductCategory[]";

	public Model function init(){
		return this;
	}

}
