component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

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

	public String function getName( String langId = NullValue() ){
		var textItem = getTextItem( arguments.langId, "NAME" );
		if ( !isNull( textItem ) ) {
			return textItem.getName();
		}
		if ( !isNull( getRawValue() ) ) {
			return getRawValue().getName( arguments.langId );
		}
		return "** Not found";
	}

	public any function onMissingMethod( required string missingMethodName ){
		return super.getImageBeanHelper().resolveGetImageMethod( missingMethodName, getImages() );
	}

	public Struct function getImage( String typeId = "horizontal" ){
		return super.getImageBeanHelper().findImageByType( getImages(), typeId );
	}
}
