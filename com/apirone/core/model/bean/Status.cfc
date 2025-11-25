component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="color" type="com.apirone.core.model.bean.SystemColor";
	property name="orderBy" type="Numeric";

	public Status function init(){
		return this;
	}

}
