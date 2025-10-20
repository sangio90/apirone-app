component extends="com.apirone.core.model.bean.Component" accessors="true" {

	property name="productItem" type="com.apirone.core.model.bean.ProductItem";

	public ComponentProductItem function init(){
		super.init();

		return this;
	}

	public Struct function extractIds(){
		return {
			"id"            = getId(),
			"productItemId" = getProductItem().getId()
		};
	}

	public String function getKindId(){
		return "PI";
	}

}
