component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = { defaultIncludes = [ "id", "name", "texts" ] }

	property name="status" type="com.apirone.core.model.bean.Status";

	public FileType function init(){
		return this;
	}

}
