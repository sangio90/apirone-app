component accessors="false" {

	public any function init(){
		return this;
	}

	// Restituisce la prima image il cui getType().getId() == typeId
	public any function findImageByType( required array images, required string typeId ){
		if ( ArrayLen( images ) ) {
			for ( var image in images ) {
				if ( IsDefined( "image.getType" ) AND image.getType().getId() EQ typeId ) {
					return image;
				}
			}
		}
		return NullValue();
	}

	// Restituisce tutte le immagini con quel typeId
	public array function getImagesByType( required array images, required string typeId ){
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
	public any function resolveGetImageMethod( required string missingMethodName, required array images ){
		if ( ReFindNoCase( "^get([A-Za-z]+)Image$", missingMethodName ) ) {
			var typeId = LCase(
				ReReplace(
					missingMethodName,
					"^get([A-Za-z]+)Image$",
					"\\1"
				)
			);
			return findImageByType( images, typeId );
		}
		return NullValue();
	}

	// Aggiunge un'immagine all'array (modifica in place)
	public void function addImage( required any image, required array images ){
		ArrayAppend( images, image );
	}

	// Rimuove immagini per typeId e ritorna il numero rimosso
	public numeric function removeImagesByType( required array images, required string typeId ){
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
