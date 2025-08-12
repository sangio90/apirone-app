component extends="com.apirone.core.model.bean.Component" accessors="true" {

	property name="line" type="com.apirone.core.model.bean.Line";
	property name="model" type="com.apirone.core.model.bean.Model";

	public ComponentCatalogSet function init(){
		return this;
	}

}
