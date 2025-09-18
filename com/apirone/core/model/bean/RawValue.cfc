component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "shortId", "code", "name" ],
		profiles        = {
			list = {
				defaultIncludes = [
					"id",
					"code",
					"shortId",
					"name",
					"nameItem",
					"status",
					"createdAt"
				]
			}
		}
	}

	property name="code" type="String";
	property name="status" type="com.apirone.core.model.bean.Status";

	public RawValue function init(){
		return this;
	}

}
