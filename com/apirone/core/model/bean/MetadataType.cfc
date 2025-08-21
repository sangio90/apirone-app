component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "code" ],
		profiles = {
			list = {
				defaultIncludes = [
					"id",
					"code",
					"name",
					"entities",
					"unit",
					"dataType",
					"createdAt",
				]
			}
		}
	}

	property name="code" type="String";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="dataType" type="com.apirone.core.model.bean.DataType";
	property name="measurementUnit" type="com.apirone.core.model.bean.MeasurementUnit";
	property name="entities" type="Array";

	public MetadataType function init(){
		return this;
	}

}
