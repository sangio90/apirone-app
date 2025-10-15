component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "shortId", "name", "code" ],
		profiles        = {
			list = {
				defaultIncludes = [
					"id",
					"status",
					"origin",
					"attribute",
					"attributeValue",
					"nameItem",
					"componentCount",
					"level",
					"orderBy",
					"productId",
					"spaces"
				]
			},
			tree = {
				defaultIncludes = [
					"id",
					"shortId",
					"status",
					"origin.id",
					"level",
					"attribute",
					"attributeValue.rawValue",
					"componentCount",
					"prices"
				]
			},
			treelight = {
				defaultIncludes = [
					"id",
					"shortId",
					"origin.id",
					"level",
					"attribute.id",
					"attribute.name",
					"attributeValue.id",
					"attributeValue.horizontalImage",
					"attributeValue.verticalImage",
					"attributeValue.rawValue.name",
					"horizontalImage",
					"verticalImage"
				]
			}
		}
	}

	property name="level" type="Numeric";
	property name="orderBy" type="String";
	property name="productId" type="String";

	property name="status" type="com.apirone.core.model.bean.Status";
	property name="origin" type="com.apirone.core.model.bean.ProductItem";
	property name="attributeValue" type="com.apirone.core.model.bean.AttributeValue";
	property name="attribute" type="com.apirone.core.model.bean.Attribute";
	property name="images" type="com.apirone.core.model.bean.File[]";

	property name="children" type="com.apirone.core.model.bean.ProductItem[]";

	property name="componentCount" type="Numeric" default=0;
	
	property name="prices" type="com.apirone.core.model.bean.Price[]";

	public ProductItem function init(){
		setChildren( [] );

		return this;
	}

	public Struct function getPrice( required String typeId ){
		for ( var price in getPrices() ) {
			if ( price.getType().getId() EQ typeId ) {
				return price;
			}
		}
	}

	public any function onMissingMethod( required string missingMethodName, required array missingMethodArguments ) {
		if ( reFindNoCase( "^get([A-Za-z]+)Image$", missingMethodName ) ) {
			var typeId = lcase( reReplace( missingMethodName, "^get([A-Za-z]+)Image$", "\1" ) );
			return getImage( typeId );
		}

		return javacast( "null", "" );
	}

	public Struct function getImage( String typeId = "horizontal" ){
		if ( Len( getImages() ) ) {
			for ( var image in getImages() ) {
				if ( image.getType().getId() EQ typeId ) {
					return image;
				}
			}
		}
	}
}
