component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="productId" type="String";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="combinationProductItems" type="Array";
	property name="descrizioneProductItems" type="String";

	public Combination function init(){
		return this;
	}

}
