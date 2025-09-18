component extends="com.apirone.core.model.bean.AbsCatalogBundle" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "font", "items", "catalogBundle" ]
	}

	property name="font" type="com.apirone.core.model.bean.Font";
	property name="items" type="com.apirone.core.model.bean.SignageConfigItem[]";
	property name="catalogBundle" type="com.apirone.core.model.bean.CatalogBundle";

	public SignageConfig function init(){
		super.init();
		return this;
	}

}
