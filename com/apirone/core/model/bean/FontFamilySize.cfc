component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = { defaultIncludes = [ "id", "name", "fontFamilyId" ] };

	property name="fontFamilyId" type="Numeric";

	public FontFamilySize function init(){
		return this;
	}

}
