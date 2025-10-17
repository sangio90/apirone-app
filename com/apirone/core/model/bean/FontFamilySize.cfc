component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"name",
		]
	}

	property name="fontFamily" type="FontFamily";

	public FontFamilySize function init(){
		return this;
	}

}