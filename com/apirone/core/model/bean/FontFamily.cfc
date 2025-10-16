component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",	//serial
			"code",	//codice 5 (codeExists)
			"name",	//nome
		]
	}

	property name="pictograms" type="Pictogram[]";

	public FontFamily function init(){
		return this;
	}

}
