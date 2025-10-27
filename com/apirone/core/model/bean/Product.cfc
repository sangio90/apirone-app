component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"shortId",
			"name",
			"code",
			"category",
			"categories",
			"line",
			"model",
			"finish"
		],
		mappers  = {},
		profiles = {
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
					"lines",
					"line",
					"model",
					"finish",
					"prices",
					"horizontalImage",
					"verticalImage"
				]
			}
		}
	}

	/*
		complex (plates)
		TODO da cancellare line/model sostituite da bundle
		TODO: move to bundle:
			  - remove properties
			  - and shortcut getMolde(), setModel()
	*/
	property name="model" type="com.apirone.core.model.bean.Model";
	property name="line" type="com.apirone.core.model.bean.Line";
	property name="finish" type="com.apirone.core.model.bean.Finish";
	property name="status" type="com.apirone.core.model.bean.Status";

	/*
		simple (fruit)
	*/
	property name="code" type="String";
	property name="positionCount" type="Numeric";
	property name="lines" type="com.apirone.core.model.bean.Line[]";

	/*
		common fields
	*/
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="category" type="com.apirone.core.model.bean.ProductCategory";

	property name="catalogBundle" type="com.apirone.core.model.bean.CatalogBundle";

	property name="prices" type="com.apirone.core.model.bean.Price[]" default=[];
	property name="images" type="com.apirone.core.model.bean.File[]";

	public Product function init(){
		variables.prices = {};
		return this;
	}

	public Struct function getPrice( required String typeId ){
		for ( var price in getPrices() ) {
			if ( price.getType().getId() EQ typeId ) {
				return price;
			}
		}
	}

	public any function onMissingMethod( required string missingMethodName ){
		// getVerticalImage, getHorizontalImage
		return super.getImageBeanHelper().resolveGetImageMethod( missingMethodName, getImages() );
	}

	public Struct function getImage( String typeId = "horizontal" ){
		return super.getImageBeanHelper().findImageByType( getImages(), typeId );
	}

}
