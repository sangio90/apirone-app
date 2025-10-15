component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "name", "code" ],
		profiles        = {
			list = {
				defaultIncludes = [
					"id",
					"name",
					"code",
					"status",
					"orderBy",
					"rawValue",
					"attributeId",
					"componentCount",
					"allowNote",
					"horizontalImage",
					"verticalImage",
					"affectToImage"
				]
			}
		}
	}

	property name="orderBy" type="Numeric" default=10;
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="rawValue" type="com.apirone.core.model.bean.RawValue";

	property name="attributeId" type="String";
	property name="componentCount" type="Numeric";

	property name="allowNote" type="Boolean";
	property name="affectToImage" type="Boolean";
	property name="images" type="com.apirone.core.model.bean.File[]";

	public AttributeValue function init(){
		return this;
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
