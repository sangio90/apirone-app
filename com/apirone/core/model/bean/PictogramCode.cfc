component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id" 	// codice 5 (codeExists) key: code / fontFamilyId
			"name",	// nome
		]
	}

	property name="image" type="File"; //files
	property name="code" type="PictogramCode"; 

	public PictogramCode function init(){
		return this;
	}

}
