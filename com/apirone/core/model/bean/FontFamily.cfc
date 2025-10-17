component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"code",
			"name",
		]
	}

	property name="code" type="String";
	property name="pictograms" type="Pictogram[]";
	property name="fontFamilySizes" type="FontFamilySize[]";

	public FontFamily function init(){
		return this;
	}

}
