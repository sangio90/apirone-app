component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="size" type="com.apirone.core.model.bean.Size";
	property name="line" type="com.apirone.core.model.bean.Line";
	property name="finish" type="com.apirone.core.model.bean.Finish";
	property name="status" type="com.apirone.core.model.bean.Status";

	/* extend */
	property name="code" type="String";
	property name="positionsCount" type="Numeric";

	property name="status" type="com.apirone.core.model.bean.Status";


	public Product function init(){
		return this;
	}

}
