component extends="com.apirone.core.model.bean.Product" accessors="true" {

	property name="finish" type="com.apirone.core.model.bean.Finish";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="catalogBundle" type="com.apirone.core.model.bean.CatalogBundle";

	public com.apirone.core.model.bean.Line function getLine(){
		return getCatalogBundle().getLine();
	}

	public com.apirone.core.model.bean.ProductCategory function getCategory(){
		return getCatalogBundle().getCategory();
	}

	public com.apirone.core.model.bean.Model function getModel(){
		return getCatalogBundle().getModel();
	}

	public ProductComplex function init(){
		return this;
	}

}
