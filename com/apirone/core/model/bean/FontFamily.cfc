component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "code", "name" ],
		profiles        = {
			list   = { defaultIncludes = [ "id", "code", "name" ] },
			detail = { defaultIncludes = [ "id", "code", "name", "sizes" ] }
		}
	}

	property name="code" type="String";
	property name="pictograms" type="Pictogram[]";
	// fontFamilySizes -> size
	property name="sizes" type="FontFamilySize[]";

	public FontFamily function init(){
		return this;
	}

}
