component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = { defaultIncludes = [ "id", "shortId", "name" ] }

	public ProductCategoryMode function init(){
		return this;
	}

}
