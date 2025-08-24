component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"code",
			"name",
			"measurementUnit",
			"dataType"
		],
		profiles = {
			list = {
				defaultIncludes = [
					"id",
					"code",
					"name",
					"entities",
					"unit",
					"dataType",
					"status",
					"measurementUnit",
					"createdAt"
				]
			}
		}
	}

	property name="code" type="String";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="dataType" type="com.apirone.core.model.bean.DataType";
	property name="measurementUnit" type="com.apirone.core.model.bean.MeasurementUnit";
	property name="entities" type="com.apirone.core.model.bean.Entity[]";

	public MetadataType function init(){
		return this;
	}

}
