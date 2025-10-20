component extends="com.apirone.core.model.bean.Component" accessors="true" {

	property name="line" type="com.apirone.core.model.bean.Line";
	property name="model" type="com.apirone.core.model.bean.Model";

	public ComponentCatalogBundle function init(){
		super.init() // set cost
		
		return this;
	}

	public Struct function extractIds(){
		return {
			"id"      = getId(),
			"lineId"  = getLine().getId(),
			"modelId" = getModel().getId()
		};
	}

	public String function getKindId(){
		return "CB";
	}

}
