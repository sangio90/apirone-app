component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="firstName" type="String";
	property name="lastName" type="String";
	property name="company" type="String";
	property name="vatNumber" type="String";
	property name="email" type="String";
	property name="phone" type="String";
	property name="country" type="com.apirone.core.model.bean.Country";
	property name="state" type="String";
	property name="city" type="String";
	property name="postalCode" type="String";
	property name="street" type="String";
	property name="type" type="com.apirone.core.model.bean.ProfileType";

	public Profile function init(){
		return this;
	}

	public String function getName(){

		if( Len( getCompany() ) ) {
			return getCompany()
		}

		return getFirstName() & " " & getLastname();
	}

}