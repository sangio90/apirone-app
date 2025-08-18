component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "shortId", "name" ],
		defaultExcludes = [],
		neverInclude    = [],
		defaults        = {},
		mappers         = {
			"descriptionItem" = function( value ){
				return value ?: {
					"id"   = "",
					"name" = "",
					"lang" = { "id" = "IT", "name" = "" }
				};
			}
		},
		profiles = {
			list = {
				defaultIncludes = [
					"id",
					"shortId",
					"name",
					"nameItem",
					"status",
					"descriptionItem",
					"createdAt",
					"code",
					"categories"
				]
			}
		}
	}

	property name="code" type="String";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="categories" type="com.apirone.core.model.bean.ProductCategory[]";

	public Finish function init(){
		return this;
	}

}
