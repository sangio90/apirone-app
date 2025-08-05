component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="combinationId" type="String";
	property name="productItem" type="com.apirone.core.model.bean.ProductItem";

	public CombinationProductItem function init(){
		return this;
	}

}
