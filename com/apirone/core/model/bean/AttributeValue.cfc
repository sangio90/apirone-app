component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "name", "code" ],
		profiles        = {
			list = {
				defaultIncludes = [
					"id",
					"name",
					"code",
					"status",
					"orderBy",
					"rawValue",
					"attributeId",
					"componentCount",
					"allowNote",
					"image",
					"affectToImage"
				]
			}
		}
	}

	property name="orderBy" type="Numeric" default=10;
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="rawValue" type="com.apirone.core.model.bean.RawValue";

	property name="attributeId" type="String";
	property name="componentCount" type="Numeric";

	property name="allowNote" type="Boolean";
	property name="affectToImage" type="Boolean";
	property name="image" type="com.apirone.core.model.bean.File";

	public AttributeValue function init(){
		return this;
	}

}
