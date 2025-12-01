component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="firstName" type="String";
	property name="lastName" type="String";
	property name="description" type="String";

	public Lead function init(){
		return this;
	}

	public String function getName(){
		return this.getFirstName() & " " & this.getLastName();
	}

}
