component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"signageConfigId",
			"height",
			"heightInPixel",
			"size",
			"rowCount",
			"charCount"
		]
	}

	property name="height" type="Numeric"; // font height
	property name="heightInPixel" type="Numeric";
	property name="rowCount" type="Numeric";
	property name="charCount" type="Numeric";
	property name="signageConfigId" type="Numeric";
	property name="size" type="FontFamilySize";

	public SignageConfigItem function init(){
		return this;
	}

}
