component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "name", "family" ],
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
					"heightWidthRatio"
				]
			}
		}
	}

	property name="code" type="String";
	property name="family" type="String";
	property name="directory" type="String";
	property name="heightWidthRatio" type="Numeric";

	public Font function init(){
		return this;
	}

}
