component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "code", "name" ],
		profiles        = {
			list   = { defaultIncludes = [ "id", "code", "name" ] },
			detail = { defaultIncludes = [ "id", "code", "name", "sizes" ] }
		}
	}

	property name="fontFamilycode" type="String";
	property name="pictograms" type="Pictogram[]";
	property name="fontFamily" type="FontFamilySize[]";

	public FontFamily function init(){
		return this;
	}

}
