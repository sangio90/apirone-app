component extends="com.apirone.core.model.bean.AbsCatalogBundle" accessors="true" {

	property name="font" type="com.apirone.core.model.bean.Font";
	property name="item" type="com.apirone.core.model.bean.SignageConfigItem[]";
	property name="CatalogBundle" type="com.apirone.core.model.bean.CatalogBundle";

	public SignageConfig function init(){
		super.init();
		return this;
	}

}
