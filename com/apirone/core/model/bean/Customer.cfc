component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="company" type="String";
	property name="description" type="String";
	property name="phone" type="String";
	property name="phoneCell" type="String";
	property name="vatNumber" type="String";
	property name="street" type="String";
	property name="postalCode" type="String";
	property name="city" type="String";
	property name="state" type="String";
	property name="country" type="com.apirone.core.model.bean.Country";
	property name="SDI" type="String";
	property name="shippingAddress" type="com.apirone.core.model.bean.ShippingProfile";
	property name="shippingAddresses" type="Array";
	property name="contactPersonName" type="String";
	property name="contactPersonEmail" type="String";

	public Customer function init(){
		return this;
	}

}
