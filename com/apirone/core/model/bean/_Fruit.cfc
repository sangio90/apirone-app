component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="code" type="String";
	property name="positionCount" type="Numeric";

	property name="status" type="com.apirone.core.model.bean.Status";

	public Fruit function init(){
		return this;
	}

}
