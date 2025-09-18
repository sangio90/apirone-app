component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "productId", "status", "name", "productItems" ]
	}

	property name="productId" type="String";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="productItems" type="com.apirone.core.model.bean.CombinationProductItem[]";

	public Combination function init(){
		return this;
	}

}
