component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="code" type="String";
	property name="pictograms" type="Pictogram[]";
	property name="sizes" type="FontFamilySize[]";

	public FontFamily function init(){
		return this;
	}

}
