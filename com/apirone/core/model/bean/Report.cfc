component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="exampleData" type="String";
	property name="exampleFile" type="String";
	property name="fileName" type="String";
	property name="status" type="com.apirone.core.model.bean.Status";

	public Report function init(){
		return this;
	}

}
