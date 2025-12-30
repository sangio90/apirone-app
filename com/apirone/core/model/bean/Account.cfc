component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="email" type="String";
	property name="pwd" type="String";
	property name="lastLoggedUserId" type="String";
	property name="serial" type="Numeric";
	property name="userCount" type="Numeric";
	property name="status" type="com.apirone.core.model.bean.Status";

	public Account function init(){

		setUserCount( 0 );

		return this;
	}

}
