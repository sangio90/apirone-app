component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "line", "model", "category" ],
		profiles        = {
			list = {
				defaultIncludes = [
					"id",
					"shortId",
					"name",
					"code",
					"nameItem",
					"status",
					"positionCount",
					"createdAt",
					"code",
					"categories",
					"category",
					"lines"
				]
			}
		}
	}


	property name="line" type="com.apirone.core.model.bean.Line";
	property name="model" type="com.apirone.core.model.bean.Model";
	property name="category" type="com.apirone.core.model.bean.ProductCategory";

	public CatalogBundle function init(){
		return this;
	}

}
