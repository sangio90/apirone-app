component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="VerticaleSyncDAO";

	/**
	 * Avvia la sincronizzazione da Verticale in background, se non ne è già in corso una.
	 * Il lock è acquisito in modo atomico dal DAO (UPDATE ... WHERE running = false):
	 * se due utenti cliccano quasi in contemporanea, solo uno riesce ad acquisirlo.
	 * userId è opzionale: uno scheduler automatico lo omette (nessun utente ha lanciato la sync).
	 */
	public Struct function run( String userId = "" ){
		var acquired = getDao().tryAcquireLock( arguments.userId );

		if ( !acquired ) {
			return { started = false, alreadyRunning = true };
		}

		// I cfthread ereditano il timeout della richiesta che li avvia: senza
		// alzarlo, cfhttp/cfquery dentro il thread verrebbero interrotti dopo i
		// 30s di default se Verticale fosse lento, anche se il thread gira ormai
		// "in background" dopo che questa run() è già tornata al chiamante
		// (bug scoperto sincronizzando il CRM: lì, con minuti di durata, si
		// manifestava sempre).
		setting requesttimeout = 1800;

		var syncDao      = getDao();
		var logger       = getLogger();
		var cacheManager = getCacheManager();
		var threadName   = "verticaleSync" & CreateUUID();

		// Scope cache (config/cacheScopes.json.cfm) che contengono bean/query costruiti
		// a partire dai dati di Verticale: senza invalidarle, dopo una sync le pagine
		// continuerebbero a servire valute/IVA/colori/varianti/materie prime/prezzi
		// dalla cache Lucee precedente, vanificando la sincronizzazione appena fatta.
		var cacheScopesToClear = [
			"Currency.bean", "VatCode.bean", "Country.bean", "PaymentMethod.bean",
			"RawProduct.bean", "RawProductType.bean", "Variant.bean", "Color.bean",
			"verticale.query"
		];

		thread name=threadName dao=syncDao logger=logger cacheManager=cacheManager cacheScopesToClear=cacheScopesToClear {
			var errors = [];

			var steps = {
				"listino prezzi"       = function(){ attributes.dao.syncPriceList(); },
				"materie prime"        = function(){ attributes.dao.syncRawProducts(); },
				"tipi materia prima"   = function(){ attributes.dao.syncRawProductTypes(); },
				"varianti"             = function(){ attributes.dao.syncVariants(); },
				"colori"               = function(){ attributes.dao.syncColors(); },
				"valute"               = function(){ attributes.dao.syncCurrencies(); },
				"aliquote IVA"         = function(){ attributes.dao.syncVatCodes(); },
				"metodi di pagamento"  = function(){ attributes.dao.syncPaymentMethods(); },
				"nazioni"              = function(){ attributes.dao.syncCountries(); }
			};

			for ( var stepName in steps ) {
				try {
					steps[ stepName ]();
				} catch ( any e ) {
					attributes.logger.error( "VerticaleSyncService. Errore sincronizzando [#stepName#]: #e.message#" );
					ArrayAppend( errors, "#stepName#: #e.message#" );
				}
			}

			for ( var scope in attributes.cacheScopesToClear ) {
				attributes.cacheManager.removeByScope( scope );
			}

			if ( ArrayLen( errors ) ) {
				attributes.dao.releaseLock( false, ArrayToList( errors, " | " ) );
			} else {
				attributes.dao.releaseLock( true );
			}
		}

		return { started = true, alreadyRunning = false };
	}

	public Struct function getStatus(){
		var record = getDao().getStatus();

		var lastCompletedAt = "";
		if ( record.recordCount AND IsDate( record.finished_at[ 1 ] ) ) {
			// finished_at è popolato con now() lato Postgres, che in questa configurazione
			// gira in UTC: la "Z" dice esplicitamente al browser che il valore è UTC, così
			// il JS lo converte nell'ora locale del viewer invece di trattarlo come locale
			// del server (altrimenti l'etichetta mostrerebbe l'ora sbagliata di 1-2h).
			lastCompletedAt = DateTimeFormat( record.finished_at[ 1 ], "yyyy-mm-dd'T'HH:nn:ss" ) & "Z";
		}

		return {
			running         = record.recordCount ? ( record.running[ 1 ] ? true : false ) : false,
			lastCompletedAt = lastCompletedAt
		};
	}

}
