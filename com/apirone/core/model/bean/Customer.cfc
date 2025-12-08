component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="company" type="String";
	property name="description" type="String";
	property name="phone" type="String";
	property name="vatNumber" type="String";
	property name="street" type="String";
	property name="postalCode" type="String";
	property name="city" type="String";
	property name="state" type="String";
	property name="country" type="com.apirone.core.model.bean.Country";
	property name="SDI" type="String";
	//property name="shippingProfile" type="com.apirone.core.model.bean.ShippingProfile";
	//property name="shippingProfiles" type="Array";
	property name="shippingProfiles" type="com.apirone.core.model.bean.ShippingProfile[]";
	property name="contactPersonName" type="String";
	property name="contactPersonEmail" type="String";

	public Customer function init(){

		setShippingProfiles( [] );

		return this;
	}

}
