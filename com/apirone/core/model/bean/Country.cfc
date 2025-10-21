component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "shortId", "name", "code" ],
		mappers         = {
			"nameItem" = function( value ){
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
					"code"
				]
			}
		}
	}

	property name="code" type="String";

    public Country function init(){
        return this;
    }

}
