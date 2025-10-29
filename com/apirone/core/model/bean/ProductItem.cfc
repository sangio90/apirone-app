component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

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

	public any function onMissingMethod( required string missingMethodName ){
		return super.getImageBeanHelper( ).resolveGetImageMethod( missingMethodName, getImages() );
	}

	public Struct function getImage( String typeId = "horizontal" ){
		return super.getImageBeanHelper( ).findImageByType( getImages(), typeId );
	}
}
