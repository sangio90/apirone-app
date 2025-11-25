/**
 * Registro per le closure (funzioni) di trasformazione dati.
 * Mappa i nomi delle stringhe (es. "creationDateTransformer") alle closure CFML reali.
 */
component {

	// Struttura che contiene tutte le closure registrate: { name: closure }
	variables.registry = {};

	/**
	 * Inizializza il registro.
	 */
	function init(){
		registerTransformers();
		return this;
	}

	/**
	 * Registra una closure di trasformazione con un nome univoco.
	 * @name Il nome stringa da usare nella configurazione Memento (es. "isoDateTransformer").
	 * @transformer La closure CFML (funzione anonima) che esegue la trasformazione.
	 */
	public function registerTransformer( required string name, required transformer ){
		// Si assicura che l'argomento 'transformer' sia una funzione (closure)
		if ( !IsCustomFunction( arguments.transformer ) ) {
			Throw(
				message = "The registered transformer must be a closure or a CFML function.",
				type    = "Mementify.TransformerRegistry.FuncionIsNotCustom"
			);
		}
		variables.registry[ arguments.name ] = arguments.transformer;
		return this;
	}

	/**
	 * Recupera una closure di trasformazione dal registro.
	 * @name Il nome stringa del transformer da recuperare.
	 * @return function La closure CFML.
	 */
	public function get( required string name ){
		if ( !StructKeyExists( variables.registry, arguments.name ) ) {
			Throw(
				message = "Transformer [#arguments.name#] not found in registry.",
				type    = "Mementify.TransformerRegistry.TransformerNotFound"
			);
		}
		return variables.registry[ arguments.name ];
	}

	private function registerTransformers(){
		registerTransformer(
			name        = "nameItem",
			transformer = function( value, memento ){
				return value ?: {
					"id"   = "",
					"name" = "",
					"lang" = { "id" = "IT", "name" = "" }
				};
			}
		);

		registerTransformer(
			name        = "descriptionItem",
			transformer = function( value, memento ){
				return value ?: {
					"id"   = "",
					"name" = "",
					"lang" = { "id" = "IT", "name" = "" }
				};
			}
		);

		registerTransformer(
			name        = "categoriesTrasformer",
			transformer = function( value, memento ){
				var result = [];

				if ( !IsArray( arguments.memento.categories ) ) {
					return result;
				}

				for ( var category in arguments.memento.categories ) {
					result.add( { "id" = category.id, "name" = category.name } );
				}

				return result;
			}
		);
	}

}
