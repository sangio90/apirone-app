component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "shortId", "name" ],
		profiles        = {
			list = {
				defaultIncludes = [
					"id",
					"name",
					"code",
					"createdAt",
					"directory",
					"family",
					"nameItem",
					"dimension",
					"status",
					"categories"
				]
			}
		}
	}

	property name="code" type="String";
	property name="family" type="String";
	property name="directory" type="String";
	property name="dimension" type="Numeric";

	public Font function init(){
		return this;
	}

}
