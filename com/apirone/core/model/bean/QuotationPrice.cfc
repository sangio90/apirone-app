component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="quotationId" type="String";
	
	//property name="amount" type="Numeric";
	property name="discount1" type="Numeric" ;
	property name="discount2" type="Numeric" ;
	property name="flatDiscount" type="Numeric";
	property name="shippingCost" type="Numeric";
	property name="totalGoods" type="Numeric";
	property name="costs" type="Numeric";
	property name="totalMultipliedByQuantity" type="Numeric";

	property name="lines" type="com.apirone.core.model.bean.PriceLine[]";
	property name="vatCode" type="com.apirone.core.model.bean.VatCode";
	property name="currency" type="com.apirone.core.model.bean.Currency";

	public QuotationPrice function init(){

		setLines( [] );

		setShippingCost( 0 );
		setDiscount1( 0 );
		setDiscount2( 0 );
		setFlatDiscount( 0 );

		return this;
	}

	public Numeric function getTaxable(){

		var total = getSubtotalBeforeFlat();

		var flatDiscount = getFlatDiscount();
		
		if ( IsNumeric( flatDiscount ) && flatDiscount > 0 ) {
			total = total - flatDiscount;
		}

		return total;
	}

	public Numeric function getSubtotalBeforeFlat(){
		
		var total = getTotalMultipliedByQuantity();

		// --- Gestione Sconti Percentuali (solo sulla merce) ---
		var discount1 = getDiscount1();
		// Se non è un numero, lo trattiamo come 0, altrimenti usiamo il valore
		if ( IsNumeric( discount1 ) && discount1 > 0 ) {
			total = total - ( total * discount1 / 100 );
		}

		var discount2 = getDiscount2();
		if ( IsNumeric( discount2 ) && discount2 > 0 ) {
			total = total - ( total * discount2 / 100 );
		}

		// --- Gestione Spese di Spedizione (dopo gli sconti percentuali) ---
		var shippingCost = getShippingCost();
		// Verifichiamo che sia un Numero e che sia maggiore di zero
		if ( IsNumeric( shippingCost ) && shippingCost > 0 ) {
			total = total + shippingCost;
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
		var totalGoods = getTotalMultipliedByQuantity();
		var taxable = getTaxable(); // Naming aggiornato
		var total = getTotal();

		// Nota: Il Vat Code, Discount, e Shipping cost sono proprietà,
		// quindi li possiamo recuperare direttamente con i getter.
		
		// 2. Popola la struttura con tutte le informazioni rilevanti
		totals["totalGoods"]         = totalGoods;               // Totale prima di sconti/spedizione
		totals["shippingCost"]       = getShippingCost();
		totals["discount1"]          = getDiscount1();
		totals["discount2"]          = getDiscount2();
		totals["flatDiscount"]       = getFlatDiscount();
		totals["subtotalBeforeFlat"] = getSubtotalBeforeFlat();
		totals["taxable"]            = getTaxable();             // Base imponibile (il nostro getTaxable() rinominato)
		totals["vatPercentage"]      = getVatCode().getValue();  // Percentuale IVA
		totals["vatAmount"]          = total - taxable;          // Importo IVA calcolato
		totals["total"]              = total;                    // Totale finale (imponibile + IVA)
		totals["costs"]              = getCosts();               // Costo totale (aggiunto per mostrare i costi di produzione)

		return totals;
	}	

}
