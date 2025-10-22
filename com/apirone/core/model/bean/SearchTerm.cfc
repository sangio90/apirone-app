component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "term" ],
		profiles        = {
			list = { defaultIncludes = [ "id", "term", "productId" ] }
		}
	}

	property name="id" type="String";
	property name="term" type="String";
	property name="product" type="com.apirone.core.model.bean.Product";

	public SearchTerm function init(){
		return this;
	}

	public String function getProductId(){
		//TODO: move to "product.id" in memento. But now not works 😪
		return this.getProduct()?.getId() ?: "";
	}

}
