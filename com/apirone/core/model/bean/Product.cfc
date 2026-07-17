component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

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
	property name="importantAttributes" type="com.apirone.core.model.bean.Attribute[]";

	property name="catalogBundle" type="com.apirone.core.model.bean.CatalogBundle";

	property name="prices" type="com.apirone.core.model.bean.Price[]" default=[];
	property name="images" type="com.apirone.core.model.bean.File[]";
	//property name="items" type="com.apirone.core.model.bean.ProductItem[]";

	property name="minQuantity" type="Numeric" default=0;
	property name="maxQuantity" type="Numeric" default=0;

	property name="marginTop" type="Numeric" default=0;
	property name="marginLeft" type="Numeric" default=0;
	property name="plateHeight" type="Numeric" default=0;
	property name="plateWidth" type="Numeric" default=0;
	
	property name="special" type="Boolean" default=false;
	property name="serial" type="Numeric";

	public Product function init(){
		variables.prices = [];
		return this;
	}

	/*
	public com.apirone.core.model.bean.Status function getModel(){
		return getCatalogBundle().getModel();
	}

	public com.apirone.core.model.bean.Status function getLine(){
		return getCatalogBundle().getLine();
	}
	*/

	public Struct function getPrice( required String typeId ){
		var allPrices = getPrices();
		if ( !IsArray( allPrices ) ) {
			writeLog( type="Error", file="application",
				text="Product.getPrice: prices is not an array for product [#( !IsNull( getId() ) ? getId() : 'null' )#]. Type: [#GetMetaData( allPrices ).name#]. Value: [#SerializeJSON( allPrices )#]" );
			return;
		}
		for ( var price in allPrices ) {
			if ( IsObject( price ) && price.getType().getId() EQ typeId ) {
				return price;
			}
		}
	}

	public String function getDescription(){
		if ( IsInstanceOf( this, "com.apirone.core.model.bean.ProductComplex" ) ) {
			return "#getLine().getName()# #getModel().getName()# (#getModel().getCode()#) #getFinish().getName()#";
		} else {
			return getName();
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
