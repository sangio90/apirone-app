component extends="com.apirone.core.model.bean.Component" accessors="true" {

	property name="SignageConfigItem" type="com.apirone.core.model.bean.SignageConfigItem";

	public ComponentSignageConfigItem function init(){
		super.init() // set cost
		
		return this;
	}

	public Struct function extractIds(){
		return {
			"id"                  = getId(),
			"signageConfigItemId" = getSignageConfigItem().getId()
		};
	}

}
