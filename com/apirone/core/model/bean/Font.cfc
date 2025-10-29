component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="code" type="String";
	property name="fontFamily" type="FontFamily";
	property name="directory" type="String";
	property name="heightWidthRatio" type="Numeric";

	public Font function init(){
		return this;
	}

}
