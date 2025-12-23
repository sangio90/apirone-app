component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="id" type="String";
	property name="term" type="String";
	property name="product" type="com.apirone.core.model.bean.Product";

	public SearchTerm function init(){
		return this;
	}

	public String function getProductId(){
		return this.getProduct()?.getId() ?: "";
	}

}
