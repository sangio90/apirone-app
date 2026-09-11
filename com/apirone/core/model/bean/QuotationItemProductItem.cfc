component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="level" type="Numeric";
	property name="quotationItemId" type="String";
	property name="quotationItemFruitId" type="Numeric";
	property name="productItem" type="com.apirone.core.model.bean.ProductItem";
	property name="origin" type="com.apirone.core.model.bean.ProductItem";
	property name="note" type="String";

	// incisione: marker della griglia del frutto scelto per il simbolo, con snapshot delle
	// coordinate (px immagine frutto orizzontale e mm) al momento del salvataggio
	property name="engravingMarkerId" type="Numeric";
	property name="engravingXPx" type="Numeric";
	property name="engravingYPx" type="Numeric";
	property name="engravingXMm" type="Numeric";
	property name="engravingYMm" type="Numeric";

	public QuotationItemProductItem function init(){
		return this;
	}

}
