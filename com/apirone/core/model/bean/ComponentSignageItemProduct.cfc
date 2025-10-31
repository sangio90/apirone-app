component extends="com.apirone.core.model.bean.Component" accessors="true" {

	// durissimo è stato scegliere il nome: ComponentSignageItemProduct

	property name="ProductItem" type="com.apirone.core.model.bean.ProductItem";
	property name="SignageConfigItem" type="com.apirone.core.model.bean.SignageConfigItem";

	public ComponentSignageItemProduct function init(){
		super.init() // set cost
		
		return this;
	}

	public Struct function extractIds(){
		return {
			"id"                  = getId(),
			"ProductItemId"       = productItem().getId(),
			"signageConfigItemId" = getSignageConfigItem().getId()
		};
	}

	public String function getKindId(){
		return "SP";
	}

}
