component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "name", "fontFamily" ],
		profiles        = {
			list = {
				defaultIncludes = [
					"id",
					"name",
					"code",
					"createdAt",
					"directory",
					"fontFamily",
					"nameItem",
					"heightWidthRatio"
				]
			}
		}
	}

	property name="code" type="String";
	property name="fontFamily" type="FontFamily";
	property name="directory" type="String";
	property name="heightWidthRatio" type="Numeric";

	public Font function init(){
		return this;
	}

}
