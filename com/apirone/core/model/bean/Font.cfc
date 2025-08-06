component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="code" type="String";
	property name="directory" type="String";
	property name="dimension" type="Numeric";

	public Font function init(){
		return this;
	}

}
