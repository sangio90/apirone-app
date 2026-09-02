component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="quotationId" type="String";
	property name="progressivo" type="String";

	// L'anticipo è espresso in percentuale sul totale OPPURE come cifra fissa:
	// uno solo dei due è valorizzato (vincolo anche sul DB).
	property name="percentuale" type="Numeric";
	property name="importo"     type="Numeric";

	property name="storedName" type="String";
	property name="directory"  type="String";
	property name="createdAt";
	property name="createdBy"  type="String";

	public QuotationProforma function init(){
		return this;
	}

	/**
	 * URL pubblico del PDF archiviato. Stessa convenzione dei documenti
	 * allegati: i file sono serviti staticamente dal repository, non da un
	 * controller.
	 */
	public String function getUri(){
		var settings = new config.Settings();
		return settings.get( "site.repository" ) & "/media/quotation-proformas/" & getDirectory() & "/" & getStoredName();
	}

	/**
	 * Anticipo in forma leggibile, per l'elenco nella dialog di stampa.
	 */
	public String function getAnticipo(){
		if ( !IsNull( getImporto() ) ) {
			return LSNumberFormat( getImporto(), "9,999.99", "it_IT" ) & " €";
		}

		if ( !IsNull( getPercentuale() ) ) {
			var p = getPercentuale();
			return ( p EQ Int( p ) ? Int( p ) : LSNumberFormat( p, "9.99" ) ) & "%";
		}

		return "";
	}

}
