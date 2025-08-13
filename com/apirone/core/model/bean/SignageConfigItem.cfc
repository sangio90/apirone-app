component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="height" type="Numeric"; // font height
	property name="heightInPixels" type="Numeric";
	property name="rowCount" type="Numeric";
	property name="charCount" type="Numeric";
	property name="signageConfigId" type="Numeric";

	public SignageConfigItem function init(){
		return this;
	}

}
