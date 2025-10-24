component accessors="false" {

	public any function init(){
		return this;
	}

	// Restituisce la prima image il cui getType().getId() == typeId
	public any function findImageByType( required Array images, required String typeId = "horizontal" ){
		if ( !IsNull( images ) AND ArrayLen( images ) ) {
			for ( var image in images ) {
				if ( IsDefined( "image.getType" ) AND image.getType().getId() EQ typeId ) {
					return image;
				}
			}
		}
		return NullValue();
	}

	// Restituisce tutte le immagini con quel typeId
	public Array function getImagesByType( required Array images, required String typeId = "horizontal" ){
		var output = [];
		if ( ArrayLen( images ) ) {
			for ( var image in images ) {
				if ( IsDefined( "image.getType" ) AND image.getType().getId() EQ typeId ) {
					ArrayAppend( output, image );
				}
			}
		}

		return output;
	}

	// Risolve metodi dinamici tipo getHorizontalImage -> findImageByType(...)
	public any function resolveGetImageMethod( required string missingMethodName, required Array images ){
		if ( ReFindNoCase( "^get([A-Za-z]+)Image$", missingMethodName ) ) {
			var typeId = LCase(
				ReReplace(
					missingMethodName,
					"^get([A-Za-z]+)Image$",
					"\1"
				)
			);
			return findImageByType( images );
		}
		return NullValue();
	}

	// Aggiunge un'immagine all'Array (modifica in place)
	public void function addImage( required any image, required Array images ){
		ArrayAppend( images, image );
	}

	// Rimuove immagini per typeId e ritorna il numero rimosso
	public numeric function removeImagesByType( required Array images, required String typeId = "horizontal" ){
		var removed = 0;
		for ( var image in images ) {
			if ( IsDefined( "image.getType" ) AND image.getType().getId() EQ typeId ) {
				ArrayDeleteAt( images, i );
				removed++;
			}
		}
		return removed;
	}

}
