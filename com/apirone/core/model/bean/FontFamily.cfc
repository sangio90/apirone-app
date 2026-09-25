component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="code" type="String";
	property name="pictograms" type="Pictogram[]";
	property name="sizes" type="FontFamilySize[]";
	// File del font (woff2/woff/ttf/otf) caricato dall'utente, usato dall'anteprima
	// segnaletica al posto dei font installati / di fonts.css. Null se non caricato.
	property name="fontFile" type="File";

	public FontFamily function init(){
		return this;
	}

}
