component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="combinationId" type="String";
	property name="productItemId" type="Numeric";
	property name="combination" type="com.apirone.core.model.bean.Combination";
	property name="productItem" type="com.apirone.core.model.bean.ProductItem";

	public CombinationProductItem function init(){
		return this;
	}

}
