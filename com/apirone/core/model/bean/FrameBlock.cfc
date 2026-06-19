component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="order" type="Numeric" default=0;
	property name="slotCount" type="Numeric" default=0;
	property name="marginTopMm" type="Numeric" default=0;
	property name="marginLeftMm" type="Numeric" default=0;

	// HAV = ruota con la placca, HOR/VER = fisso
	property name="orientationMode" type="String" default="HAV";

	// true = l'utente può ruotare il blocco in modo indipendente nel preventivo
	property name="rotatable" type="Boolean" default=false;

	property name="frameId" type="String";

	public FrameBlock function init(){
		return this;
	}

}
