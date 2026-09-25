component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="fontFamilyId" type="Numeric";
	property name="enabledPictograms" type="Boolean" default="true";
	// Dimensioni (px) dei pittogrammi per questa altezza: [ { code = "<man>", width, height } ]
	property name="pictogramDimensions" type="Array";

	public FontFamilySize function init(){
		return this;
	}

}
