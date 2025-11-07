component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="important" type="Boolean";
	property name="suffixCode" type="String";
	property name="exportCode" type="com.apirone.core.model.bean.ExportCode";
	property name="rawValue" type="com.apirone.core.model.bean.RawValue";

	public ExportCode function init(){
		return this;
	}

}
