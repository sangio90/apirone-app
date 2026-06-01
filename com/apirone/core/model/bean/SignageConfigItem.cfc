component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="height" type="Numeric"; // font height //TODO: to remove
	property name="heightInPixel" type="Numeric";
	property name="rowCount" type="Numeric";
	property name="charCount" type="Numeric";
	property name="signageConfigId" type="Numeric";
	property name="size" type="FontFamilySize";
	property name="lineHeights" type="Array";

	public SignageConfigItem function init(){
		return this;
	}

}
