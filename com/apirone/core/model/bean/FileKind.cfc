component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = { defaultIncludes = [ "id", "shortId", "name" ] }

	property name="status" type="com.apirone.core.model.bean.Status";

	public FileKind function init(){
		return this;
	}

}
