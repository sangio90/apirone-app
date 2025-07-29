component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="productId" type="String";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="combinationProductItems" type="com.apirone.core.model.bean.CombinationProductItem[]";
	// property name="descrizioneProductItems" type="String";

	public Combination function init(){
		return this;
	}

}
