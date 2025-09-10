component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"name",
			"type",
			"processingType",
			"measurementUnit"
		]
	}

	property name="type" type="com.apirone.core.model.bean.RawProductType";
	property name="processingType" type="com.apirone.core.model.bean.ProcessingType";
	property name="measurementUnit" type="com.apirone.core.model.bean.MeasurementUnit";
	property name="variants" type="com.apirone.core.model.bean.Variant[]";

	public RawProduct function init(){
		return this;
	}

}
