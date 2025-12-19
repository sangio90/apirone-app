component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="quotationId" type="String";
	
	//property name="amount" type="Numeric";
	property name="discount1" type="Numeric" ;
	property name="discount2" type="Numeric" ;
	property name="shippingCost" type="Numeric";
	property name="totalGoods" type="Numeric";

	property name="lines" type="com.apirone.core.model.bean.PriceLine[]";
	property name="vatCode" type="com.apirone.core.model.bean.VatCode";
	//property name="items" type="com.apirone.core.model.bean.QuotationItemPrice[]";

	public QuotationPrice function init(){

		setLines( [] );

		setShippingCost( 0 );
		setDiscount1( 0 );
		setDiscount2( 0 );

		return this;
	}

	public Numeric function getTaxable(){
		
		var total = getTotalGoods();
		
		// --- Gestione Spese di Spedizione ---
		var shippingCost = getShippingCost();
		// Verifichiamo che sia un Numero e che sia maggiore di zero
		if ( IsNumeric( shippingCost ) && shippingCost > 0 ) {
			total = total + shippingCost;
		} 

		var discount1 = getDiscount1();
		// Se non è un numero, lo trattiamo come 0, altrimenti usiamo il valore
		if ( IsNumeric( discount1 ) && discount1 > 0 ) {
			total = total - ( total * discount1 / 100 );
		}

		var discount2 = getDiscount2();
		if ( IsNumeric( discount2 ) && discount2 > 0 ) {
			total = total - ( total * discount2 / 100 );
		}

		return total;
	}

	public Numeric function getTotal(){
		var total = getTaxable();

		total = total + ( total * getVatCode().getValue() / 100 );

		return total;
	}

	public Struct function getCalculatedTotals() {
		
		// Dichiarazione della variabile locale di tipo Struct
		var totals = {}; 
		
		// 1. Recupera i valori calcolati (richiama le funzioni che abbiamo definito)
		var totalGoods = getTotalGoods();
		var taxable = getTaxable(); // Naming aggiornato
		var total = getTotal();

		// Nota: Il Vat Code, Discount, e Shipping cost sono proprietà,
		// quindi li possiamo recuperare direttamente con i getter.
		
		// 2. Popola la struttura con tutte le informazioni rilevanti
		totals["totalGoods"]    = totalGoods;               // Totale prima di sconti/spedizione
		totals["shippingCost"]  = getShippingCost();
		totals["discount1"]     = getDiscount1();
		totals["discount2"]     = getDiscount2();
		totals["taxable"]       = getTaxable();             // Base imponibile (il nostro getTaxable() rinominato)
		totals["vatPercentage"] = getVatCode().getValue();  // Percentuale IVA
		totals["vatAmount"]     = total - taxable;          // Importo IVA calcolato
		totals["total"]         = total;                    // Totale finale (imponibile + IVA)

		return totals;
	}	

}
