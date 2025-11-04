component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="fontFamilyId" type="Numeric";
	property name="enabledPictograms" type="Boolean" default="true";

	public FontFamilySize function init(){
		return this;
	}

}
