component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = {
		defaultIncludes = [],
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
					"nameItem",
					"descriptionItem",
					"thickness.id",
					"status",
					"nameItem",
					"createdAt",
					"code",
					"categories"
				]
			}
		}
	}

	property name="code" type="String";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="thickness" type="com.apirone.core.model.bean.Thickness";
	property name="categories" type="com.apirone.core.model.bean.ProductCategory[]";

	public Line function init(){
		return this;
	}

}
