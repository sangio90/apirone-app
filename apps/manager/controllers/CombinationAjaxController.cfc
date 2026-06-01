component extends="com.apirone.core.controller.AbsController" {

	function findByListOfProductItemIds( event, rc, prc ){
		var result = super.getResult();
		var rows = super.fire( "combination.findByListOfProductItemIds", [ rc.productItemIds ] );

		// Le chiamate dalla placca Vue inviano "orientation" (HOR/VER) e richiedono
		// il nuovo formato { combinations: [...] } con filtro per orientamento.
		// Le chiamate legacy (accessori) non inviano orientamento e richiedono il
		// vecchio formato { horizontalImage: "uri" } senza filtro per tipo file.
		if ( structKeyExists( rc, "orientation" ) && len( rc.orientation ) ) {
			// Dato che le combinazioni potrebbero essere su 3 valori di attributi
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
			var typeId = rc.orientation == "VER" ? "vertical" : "horizontal";
			var combinations = [];

			for ( var row in rows ) {
				var params = { combinationId = row.getId(), typeId = typeId };
				var combinationImage = super.fire( "file.list", params );
				if ( len( combinationImage ) ) {
					var productItemIds = [];
					for ( var cpi in row.getProductItems() ) {
						productItemIds.append( cpi.getProductItem().getId() );
					}
					combinations.append( {
						"image": combinationImage[ 1 ].getUri(),
						"productItemIds": productItemIds
					} );
				}
			}

			result.setData( { "combinations": combinations } );
		} else {
			var data = { "horizontalImage": null };

			for ( var row in rows ) {
				var params = { combinationId = row.getId() };
				var combinationImage = super.fire( "file.list", params );
				if ( len( combinationImage ) ) {
					data.horizontalImage = combinationImage[ 1 ].getUri();
					break;
				}
			}

			result.setData( data );
		}

		event.setValue( "result", result );
	}
}
