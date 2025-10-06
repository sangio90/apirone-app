component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"shortId",
			"name",
			"company",
			"description",
			"phone",
			"phoneCell",
			"vatNumber",
			"street",
			"postalCode",
			"city",
			"state",
			"country",
			"SDI"
		],
		profiles = {}
	}

	property name="name" type="String";
	property name="company" type="String";
	property name="description" type="String";
	property name="phone" type="String";
	property name="phoneCell" type="String";
	property name="vatNumber" type="String";
	property name="street" type="String";
	property name="postalCode" type="String";
	property name="city" type="String";
	property name="state" type="String";
	property name="country" type="String";
	property name="SDI" type="String";

	public Customer function init(){
		return this;
	}

}