component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="id" type="Numeric";
	property name="width" type="Numeric";
	property name="height" type="Numeric";
	property name="pictogramId" type="Numeric";
	property name="fontFamilySizeId" type="Numeric";

	public PictogramDimension function init(){
		return this;
	}

}
