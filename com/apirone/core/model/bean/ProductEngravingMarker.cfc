component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	// frutto e attributo radice dell'incisione (IS, II oppure IL)
	property name="productId" type="String";
	property name="attributeId" type="String";

	// numero mostrato sul marker, progressivo per frutto + attributo
	property name="order" type="Numeric" default=0;

	// centro del marker sull'immagine orizzontale del frutto: px nativi dell'immagine e mm
	property name="xPx" type="Numeric" default=0;
	property name="yPx" type="Numeric" default=0;
	property name="xMm" type="Numeric" default=0;
	property name="yMm" type="Numeric" default=0;

	public ProductEngravingMarker function init(){
		return this;
	}

}
