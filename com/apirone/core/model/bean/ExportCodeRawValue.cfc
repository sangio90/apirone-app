component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="important" type="Boolean";
	property name="exportCode" type="com.apirone.core.model.bean.ExportCode";
	property name="rawValue" type="com.apirone.core.model.bean.RawValue";
	property name="attribute" type="com.apirone.core.model.bean.Attribute";

	public ExportCodeRawValue function init(){
		return this;
	}

}
