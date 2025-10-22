component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "code", "name", "sizes" ],
		profiles        = {
			list   = { defaultIncludes = [ "id", "code", "name", "sizes" ] },
			detail = { defaultIncludes = [ "id", "code", "name", "sizes" ] }
		}
	}

	property name="code" type="String";
	property name="pictograms" type="Pictogram[]";
	property name="sizes" type="FontFamilySize[]";

	public FontFamily function init(){
		return this;
	}

}
