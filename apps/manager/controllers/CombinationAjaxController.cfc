component extends="com.apirone.core.controller.AbsController" {

	function findByListOfProductItemIds( event, rc, prc ){
		var result = super.getResult();
		// Da verificare se è come vogliono in Apir: dato che le combinazioni potrebbero essere su 3 valori di attributi
		// per un frutto che ha 4 o 5 attributi totali, non bisogna per forza cercare l'esatta corrispondenza tra i
		// valori selezionati e i valori richiesti dalla combinazione.
		// Quindi viene effettuata una ricerca in questo modo: cerca tutte le combinazioni che hanno almeno uno dei
		// productItemsId specificati.
		// Per ognuna di queste controlla che non ci siano attributi in conflitto (cioè la combinazione
		// necessita che l'attributo XYZ="ABC" e il frutto è impostato con attributo XYZ="DEF").
		//
		// Esempio:
		// Combinazione 1: Pulsante Forma="Avio", Finitura="Ottone", Modello="Commutatore"   -> immagine1.png
		// Combinazione 2: Pulsante Incisione="NO",                                          -> immagine2.png
		// API chiamata con con Forma="Avio", Finitura="Ottone", Modello="Commutatore", Incisione="NO" -> ritorna immagine1.png e immagine2.png
		// API chiamata con con Forma="Avio", Finitura="Ottone", Modello="Commutatore", Incisione="SI" -> ritorna immagine1.png
		// API chiamata con con Forma="Avio", Finitura="Acciaio", Modello="Commutatore", Incisione="NO" -> ritorna immagine2.png
		// API chiamata con con Forma="Avio", Finitura="Acciaio", Modello="Commutatore", Incisione="SI" -> non ritorna niente
		var rows = super.fire( "combination.findByListOfProductItemIds", [ rc.productItemIds ] );

		// Determina il tipo di immagine in base all'orientamento del prodotto
		var typeId = rc.orientation == "VER" ? "vertical" : "horizontal";

		var images = [];

		for ( var row in rows ) {
			var params = { combinationId = row.getId(), typeId = typeId };
			var combinationImage = super.fire( "file.list", params );
			if ( len( combinationImage ) ) {
				images.append( combinationImage[ 1 ].getUri() );
			}
		}

		result.setData( { "images": images } );
		event.setValue( "result", result );
	}
}
