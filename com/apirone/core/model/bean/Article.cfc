component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="code" type="String";
	property name="externalId" type="String";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="type" type="com.apirone.core.model.bean.ArticleType";
	property name="price" type="com.apirone.core.model.bean.Price";

	public Article function init(){
		return this;
	}

}
