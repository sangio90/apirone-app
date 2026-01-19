/*
	Thanks to:
	https://github.com/coldbox-modules/mementifier

	TODO:
		- add Transformer Bean concept Registry like TransformerProductItem
		  (add transformer argument in memento and search that method in relative class)
		- use multi-thread each() function in convert list for better performance
		- create a package/module for this utility

*/

component {

	variables.settings            = {};
	variables.configDirectory     = "";
	variables.transformerRegistry = {};
	variables.mementoRulesCache   = {};
	variables.metadataCache       = {};
	variables.stats               = {};

	function init(
		required Struct settings        = {},
		required String configDirectory = "/config/mementos/",
		required Struct transformerRegistry
	){
		var thisSettings = {
			iso8601Format     = settings?.iso8601Format ?: false,
			dateMask          = settings?.dateMask ?: "yyyy-MM-dd",
			timeMask          = settings?.timeMask ?: "HH:mm:ss",
			nullDefaultValue  = settings?.nullDefaultValue ?: null,
			trustedGetters    = settings?.trustedGetters ?: true, // true: the fastest option
			convertToTimezone = settings?.convertToTimezone ?: "",
			autoCastBooleans  = settings?.autoCastBooleans ?: false
		}

		variables.settings            = thisSettings;
		variables.configDirectory     = arguments.configDirectory;
		variables.transformerRegistry = arguments.transformerRegistry;

		// Inizializza le statistiche
		variables.stats = {
			"conversionsCount" = 0,
			"totalTimeMs"      = 0,
			"cacheHits"        = { "metadata" = 0, "rules" = 0 },
			"cacheMisses"      = { "metadata" = 0, "rules" = 0 },
			"startedAt"        = Now()
		};

		// Per-target (entity) statistics to identify slow object types
		// Structure: variables.stats.targets[entityName] = { count, totalTimeMs, maxTimeMs, durations = [] }
		variables.stats.targets = {};

		return this
	}

	/**
	 * Construct a memento representation from an entity according to it's defined this.memento properties.
	 * You can also override those properties defined in a class by using the arguments in this method.
	 *
	 * @target         	 The target object to convert
	 * @includes         The properties array or list to build the memento with alongside the default includes
	 * @excludes         The properties array or list to exclude from the memento alongside the default excludes
	 * @mappers          A struct of key-function pairs that will map properties to closures/lambadas to process the item value.  The closure will transform the item value.
	 * @defaults         A struct of key-value pairs that denote the default values for properties if they are null, defaults for everything are a blank string.
	 * @ignoreDefaults   If set to true, default includes and excludes will be ignored and only the incoming 'includes' and 'excludes' list will be used.
	 * @trustedGetters   If set to true, getters will not be checked for in the 'this' scope before trying to invoke them.
	 * @iso8601Format    If set to true, will use the ISO 8601 standard for formatting dates
	 * @dateMask         The date mask to use when formatting datetimes. Only used if iso8601Format is false.
	 * @timeMask         The time mask to use when formatting datetimes. Only used if iso8601Format is false.
	 * @profile          The profile to use instead of the defaults
	 * @autoCastBooleans Auto cast boolean values if they are not numeric and isBoolean().
	 */
	struct function convert(
		required Any target,
		String profile         = "",
		includes               = "",
		excludes               = "",
		Struct mappers         = {},
		Struct defaults        = {},
		Boolean ignoreDefaults = false,
		Boolean trustedGetters,
		Boolean iso8601Format,
		String dateMask,
		String timeMask,
		Boolean autoCastBooleans
	){
		// Track stats: inizio timing
		var startTick = GetTickCount();

		var target = Duplicate( arguments.target );

		var metadata = $getCachedMetadata( target );
		var entityName = metadata.keyExists( "fullname" ) ? ListLast( metadata.fullname, "." ) : "";

		var externalRules = $getRulesFromHierarchy( target ); // from files

		if ( externalRules.len() ) {
			var memento = externalRules
		} else {
			// TODO: inline rules to remove
			var memento = arguments.target.memento;
		}

		local.includes = Duplicate( arguments.includes );
		local.excludes = Duplicate( arguments.excludes );

		// var memento = target.memento;

		if ( IsSimpleValue( local.includes ) ) {
			local.includes = ListToArray( local.includes );
		}

		if ( IsSimpleValue( local.excludes ) ) {
			local.excludes = ListToArray( local.excludes );
		}

		// Param Default Memento Settings
		// We do it here, because ACF caches crap!
		var thisMemento = {
			"autoCastBooleans" = IsNull( memento.autoCastBooleans ) ? variables.settings.autoCastBooleans : memento.autoCastBooleans,
			"dateMask"         = IsNull( memento.dateMask ) ? variables.settings.dateMask : memento.dateMask,
			"defaults"         = IsNull( memento.defaults ) ? {} : memento.defaults,
			"defaultIncludes"  = IsNull( memento.defaultIncludes ) ? [] : memento.defaultIncludes,
			"defaultExcludes"  = IsNull( memento.defaultExcludes ) ? [] : memento.defaultExcludes,
			"iso8601Format"    = IsNull( memento.iso8601Format ) ? variables.settings.iso8601Format : memento.iso8601Format,
			"mappers"          = IsNull( memento.mappers ) ? {} : memento.mappers,
			"neverInclude"     = IsNull( memento.neverInclude ) ? [] : memento.neverInclude,
			"profiles"         = IsNull( memento.profiles ) ? {} : memento.profiles,
			"timeMask"         = IsNull( memento.timeMask ) ? variables.settings.timeMask : variables.settings.timeMask,
			"trustedGetters"   = IsNull( memento.trustedGetters ) ? variables.settings.trustedGetters : variables.settings.trustedGetters
		};

		// Param arguments according to instance > settings chain precedence
		arguments.trustedGetters   = IsNull( arguments.trustedGetters ) ? thisMemento.trustedGetters : arguments.trustedGetters;
		arguments.iso8601Format    = IsNull( arguments.iso8601Format ) ? thisMemento.iso8601Format : arguments.iso8601Format;
		arguments.dateMask         = IsNull( arguments.dateMask ) ? thisMemento.dateMask : arguments.dateMask;
		arguments.timeMask         = IsNull( arguments.timeMask ) ? thisMemento.timeMask : arguments.timeMask;
		arguments.autoCastBooleans = IsNull( arguments.autoCastBooleans ) ? thisMemento.autoCastBooleans : arguments.autoCastBooleans;

		// Choose a profile
		// ROB: forse qui dovrebbe essere profileCorrente.defaultinclude che mergia thisMememento.defaultinclude
		if ( Len( arguments.profile ) && thisMemento.profiles.keyExists( arguments.profile ) ) {
			StructAppend(
				thisMemento,
				thisMemento.profiles[ arguments.profile ],
				true
			);
		}

		var resolvedMappers = {};
		for ( var prop in thisMemento.mappers ) {
			var transformerNameOrClosure = thisMemento.mappers[ prop ];

			if ( IsSimpleValue( transformerNameOrClosure ) ) {
				// E' una stringa! Risolvila tramite il registro iniettato.
				resolvedMappers[ prop ] = variables.transformerRegistry.get( transformerNameOrClosure );
			} else {
				// E' già una closure (definita direttamente nel codice), usala com'è
				resolvedMappers[ prop ] = transformerNameOrClosure;
			}
		}
		// Sostituiamo i transformer originali (con stringhe) con quelli risolti (con closure).
		thisMemento.mappers = resolvedMappers;

		// Do we have a * for auto includes of all properties in the object
		if ( ArrayLen( thisMemento.defaultIncludes ) && thisMemento.defaultIncludes[ 1 ] == "*" ) {
			// assign the default includes to be all properties
			// however, we exclude anything with an inject key and anything on the default exclude list
			thisMemento.defaultIncludes = $getDeepProperties()
				.filter( function( item ){
					return (
						!arguments.item.keyExists( "inject" ) &&
						!thisMemento.defaultExcludes.findNoCase( arguments.item.name )
					);
				} )
				.map( function( item ){
					return arguments.item.name;
				} );
		}

		// Incorporate Defaults if not ignored
		if ( !arguments.ignoreDefaults ) {
			local.includes.append( thisMemento.defaultIncludes, true );
			local.excludes.append(
				thisMemento.defaultExcludes.filter( function( item ){
					// Filter out if incoming includes was specified
					return !includes.findNoCase( arguments.item );
				} ),
				true
			);
		}

		// Incorporate Memento Mappers, and Defaults
		thisMemento.mappers.append( arguments.mappers, true );
		thisMemento.defaults.append( arguments.defaults, true );

		// Start processing pipeline on the includes properties
		var result          = {};
		var mappersKeyArray = thisMemento.mappers.keyArray();

		// Filter out exclude items and never include items
		local.includes = local.includes.filter( function( item ){
			// We do this, as it could have an alias.
			var targetItem = ListLast( arguments.item, ":" );
			return !ArrayFindNoCase( excludes, targetItem )
			&& !ArrayFindNoCase( thisMemento.neverInclude, targetItem )
			&& targetItem != "";
		} );

		// Remove duplicates
		local.includes = ListToArray( ArrayToList( local.includes ).ListRemoveDuplicates() );
		local.excludes = ListToArray( ArrayToList( local.excludes ).ListRemoveDuplicates() );

		// Process Includes
		// Please keep at a traditional LOOP to avoid closure reference memory leaks and slowness on some engines.
		for ( var item in local.includes ) {
			var nestedIncludes = "";

			// Is this a nested include?
			if ( ListLen( item, "." ) > 1 ) {
				// Nested List by removing relationship root.
				nestedIncludes = ListDeleteAt( item, 1, "." );
				// Retrieve the relationship
				item           = ListFirst( item, "." );
			}

			// Parse property definition: supports "prop", "prop:alias", "prop$Type", "prop:alias$Type"
			var parsedDef = $parsePropertyDefinition( item );
			var thisAlias = parsedDef.alias;
			var castType  = parsedDef.castType;
			item          = parsedDef.prop;

			var thisValue = NullValue()

			if ( arguments.trustedGetters || StructKeyExists( target, "get#item#" ) ) {
				try {
					thisValue = Invoke( target, "get#item#" );
				} catch ( any e ) {
					// Unless trusted getters is on and there is a mapper for this item rethrow the exception.
					if ( !arguments.trustedGetters || !StructKeyExists( arguments.mappers, item ) ) {
						rethrow;
					}
				}
				// If the key doesn't exist and there is no mapper for the item, go to the next item.
			} else if ( !StructKeyExists( thisMemento.mappers, item ) ) {
				continue;
			}

			// Verify Nullness
			thisValue = IsNull( thisValue ) ? (
				ArrayContainsNoCase( thisMemento.defaults.keyArray(), item ) ? (
					IsNull( thisMemento.defaults[ item ] ) ? Javacast( "null", "" ) : thisMemento.defaults[ item ]
				) : variables.settings.nullDefaultValue
			) : thisValue;

			if ( IsNull( thisValue ) ) {
				result[ thisAlias ] = Javacast( "null", "" );
			}
			// Match timestamps + date/time objects
			else if (
				IsSimpleValue( thisValue )
				&&
				(
					ReFind( "^\{ts ([^\}])*\}", thisValue ) // Lucee and BoxLang default date string format
					||
					ReFind( "^\d{4}-\d{2}-\d{2}", thisValue ) // ACF date format begins with YYYY-MM-DD
				)
			) {
				var dateInstance = thisValue;

				try {
					// Iso Date?
					if ( arguments.iso8601Format ) {
						var timeFormat      = TimeFormat( dateInstance, "HH:mm:SSXXX" );
						result[ thisAlias ] = DateTimeFormat( dateInstance, "yyyy-MM-dd" ) & "T" & timeFormat;
					} else {
						var timeFormat      = TimeFormat( dateInstance, timeMask );
						result[ thisAlias ] = Trim( DateFormat( dateInstance, arguments.dateMask ) & " " & timeFormat );
					}
				} catch ( any e ) {
					result[ thisAlias ] = dateInstance;
				}
			}

			// Strict Type Boolean Values
			else if ( arguments.autoCastBooleans && !IsNumeric( thisValue ) && IsBoolean( thisValue ) ) {
				result[ thisAlias ] = Javacast( "Boolean", thisValue );
			}

			// Simple Values
			else if ( IsSimpleValue( thisValue ) ) {
				result[ thisAlias ] = thisValue;
			}

			// Array Collections
			else if ( IsArray( thisValue ) ) {
				// Map Items into result object
				result[ thisAlias ] = [];
				// Again we use traditional loops to avoid closure references and slowness on some engines

				for ( var thisIndex = 1; thisIndex <= ArrayLen( thisValue ); thisIndex++ ) {
					var arrayItem = thisValue[ thisIndex ];

					// Se l'elemento è un simple value, usalo direttamente
					if ( IsSimpleValue( arrayItem ) ) {
						result[ thisAlias ][ thisIndex ] = arrayItem;
					}
					// Se è un component, processa il memento
					else if ( IsValid( "component", arrayItem ) ) {
						// only get mementos from relationships that have mementos, in the event that we have an already-serialized array of structs

						// var nestedIncludes = $buildNestedMementoList( local.includes, item );

						// If no nested includes requested, then default them
						// Use resolved local.includes so nested keys from defaults/profiles are considered
						var nestedIncludes = $buildNestedMementoList( local.includes, item );

						// Determine if we should ignore defaults for the child
						// - If nestedIncludes has entries (e.g., ["id", "name"]), force ignoreDefaults=true (use ONLY those properties)
						// - If nestedIncludes is empty, force ignoreDefaults=false (use the child's defaultIncludes)
						// This prevents the parent's ignoreDefaults from cascading incorrectly when no specific nested properties are requested
						var shouldIgnoreDefaults = nestedIncludes.len() > 0;

						// Process the item memento
						result[ thisAlias ][ thisIndex ] = convert(
							target          : arrayItem,
							includes        : nestedIncludes,
							excludes        : $buildNestedMementoList( local.excludes, item ),
							mappers         : $buildNestedMementoStruct( mappers, item ),
							defaults        : $buildNestedMementoStruct( defaults, item ),
							// cascade the ignore defaults down ONLY if specific nested includes are requested
							ignoreDefaults  : shouldIgnoreDefaults,
							// Cascade the arguments to the children
							profile         : arguments.profile,
							trustedGetters  : arguments.trustedGetters,
							iso8601Format   : arguments.iso8601Format,
							dateMask        : arguments.dateMask,
							timeMask        : arguments.timeMask,
							autoCastBooleans: arguments.autoCastBooleans
						);
					}
					// Altrimenti (struct, altro), usalo così com'è
					else {
						result[ thisAlias ][ thisIndex ] = arrayItem;
					}
				}
			}

			// Single Object Relationships
			else if ( IsValid( "component", thisValue ) ) {
				// If no nested includes requested, then default them
				// Use resolved local.includes so nested keys from defaults/profiles are considered
				var nestedIncludes = $buildNestedMementoList( local.includes, item );

				// Determine if we should ignore defaults for the child
				// - If nestedIncludes has entries (e.g., ["id", "name"]), force ignoreDefaults=true (use ONLY those properties)
				// - If nestedIncludes is empty, force ignoreDefaults=false (use the child's defaultIncludes)
				// This prevents the parent's ignoreDefaults from cascading incorrectly when no specific nested properties are requested
				var shouldIgnoreDefaults = nestedIncludes.len() > 0;

				// Process the item memento
				var thisItemMemento = convert(
					target          : thisValue,
					includes        : nestedIncludes,
					excludes        : $buildNestedMementoList( local.excludes, item ),
					// excludes        : ["name", "hex"],
					mappers         : $buildNestedMementoStruct( mappers, item ),
					defaults        : $buildNestedMementoStruct( defaults, item ),
					// cascade the ignore defaults down ONLY if specific nested includes are requested
					ignoreDefaults  : shouldIgnoreDefaults,
					// Cascade the arguments to the children
					profile         : arguments.profile,
					trustedGetters  : arguments.trustedGetters,
					iso8601Format   : arguments.iso8601Format,
					dateMask        : arguments.dateMask,
					timeMask        : arguments.timeMask,
					autoCastBooleans: arguments.autoCastBooleans
				);


				// Do we have a root already for this guy?
				if ( result.keyExists( thisAlias ) ) {
					StructAppend( result[ thisAlias ], thisItemMemento, false );
				} else {
					result[ thisAlias ] = thisItemMemento;
				}
			}

			// we don't know what to do with this item so we return as-is
			else {
				result[ thisAlias ] = thisValue;
			}

			// Apply casting if specified in the property definition
			if ( Len( castType ) && result.keyExists( thisAlias ) ) {
				result[ thisAlias ] = $applyCast( result[ thisAlias ], castType );
			}
		}

		for ( var item in result ) {
			// Do we have a mapper according to this key?
			if ( mappersKeyArray.findNoCase( item ) ) {
				// ACF compat
				var thisMapper = thisMemento.mappers[ item ];
				// Transform it
				result[ item ] = thisMapper( result[ item ], result );
				;
			} else {
				// Check for null values
				result[ item ] = ( !result.keyExists( item ) || IsNull( result[ item ] ) ) ? NullValue() : result[ item ];
			}
		}

		// Track stats: fine timing e aggiornamento contatori
		var duration = GetTickCount() - startTick;
		variables.stats.conversionsCount++;
		variables.stats.totalTimeMs += duration;

		// Update per-target statistics (track which entity types are slow)
		try {
			if ( Len( entityName ) ) {
				if ( NOT StructKeyExists( variables.stats.targets, entityName ) ) {
					variables.stats["targets"][ entityName ] = {
						"count"       = 0,
						"totalTimeMs" = 0,
						"maxTimeMs"   = 0,
						"durations"   = []
					};
				}

				var tstat         = variables.stats["targets"][ entityName ];
				tstat.count       = tstat.count + 1;
				tstat.totalTimeMs = tstat.totalTimeMs + duration;
				if ( duration gt tstat.maxTimeMs ) {
					tstat.maxTimeMs = duration;
				}
				// Keep only the most recent N samples to limit memory (N=200)
				ArrayAppend( tstat.durations, duration );
				if ( ArrayLen( tstat.durations ) gt 200 ) {
					ArrayDeleteAt( tstat.durations, 1 );
				}
				variables.stats["targets"][ entityName ] = tstat;
			}
		} catch ( any e ) {
			// non-fatal: ensure stats update doesn't break conversion
		}

		// Return memento
		return result;
	}

	/**
	 * Convert a list of object
	 */
	public function convertList(
		required list,
		profile  = "",
		includes = ""
	){
		var result = [];

		for ( var item in arguments.list ) {
			result.append(
				convert(
					target   = item,
					profile  = arguments.profile,
					includes = arguments.includes
				)
			);
		}
		return result;
	}

	/**
	 * Recupera le statistiche correnti sulle conversioni e l'uso della cache.
	 *
	 * @return struct Le statistiche con contatori e metriche calcolate.
	 */
	public struct function getStats(){
		var stats = Duplicate( variables.stats );

		// avgTimeMs è il tempo medio in millisecondi che ci vuole per fare una conversione (chiamata a convert()).
		stats[ "avgTimeMs" ]   = stats.conversionsCount > 0 ? Round( stats.totalTimeMs / stats.conversionsCount ) : 0;
		stats[ "uptimeHours" ] = DateDiff( "h", stats.startedAt, Now() );

		// Calcola percentuali cache hit rate
		var totalMetadataRequests = stats.cacheHits.metadata + stats.cacheMisses.metadata;
		var totalRulesRequests    = stats.cacheHits.rules + stats.cacheMisses.rules;

		/*
			cacheHitRate contiene le percentuali di successo della cache (cache hit rate) per metadata e rules.
			È un calcolo che ti dice su 100 richieste, quante volte ho trovato il dato in cache invece di doverlo ricaricare.
			95-100% = Ottimo
			70-94%  = Buono
			< 70%   = Problema: troppi cache miss, forse cache troppo piccola o dati che cambiano spesso
			Ti dice se la cache dei metadata e delle rules sta funzionando bene.
			Se vedi percentuali basse, significa che stai facendo tante chiamate a GetMetaData() o tanti caricamenti di file JSON, rallentando l'app.
		*/
		stats[ "cacheHitRate" ] = {
			"metadata" = totalMetadataRequests > 0 ? Round( ( stats.cacheHits.metadata / totalMetadataRequests ) * 100 ) : 0,
			"rules"    = totalRulesRequests > 0 ? Round( ( stats.cacheHits.rules / totalRulesRequests ) * 100 ) : 0
		};

		// Per-target summaries (avg, p95, p99, max)
		StructInsert( stats, "targets", {}, true );

		for ( var target in variables.stats.targets ) {
			var raw     = variables.stats.targets[ target ];
			var summary = {};

			summary[ "count" ]       = raw.count;
			summary[ "totalTimeMs" ] = raw.totalTimeMs;
			summary[ "avgTimeMs" ]   = raw.count gt 0 ? Round( raw.totalTimeMs / raw.count ) : 0;
			summary[ "maxTimeMs" ]   = raw.maxTimeMs ?: 0;
			// compute percentiles on the stored durations (recent samples)

			var durations = Duplicate( raw.durations );

			if ( ArrayLen( durations ) gt 0 ) {
				// sort numeric durations ascending for percentile calculation
				ArraySort( durations, "numeric" );

				var durationCount = ArrayLen( durations );

				var idx95 = Ceiling( 0.95 * durationCount );
				var idx99 = Ceiling( 0.99 * durationCount );

				summary[ "p95" ] = durations[ idx95 ];
				summary[ "p99" ] = durations[ idx99 ];
			} else {
				summary[ "p95" ] = 0;
				summary[ "p99" ] = 0;
			}

			StructInsert( stats.targets, target, summary, true );
		}

		return stats;
	}

	/**
	 * Resetta i contatori delle statistiche.
	 * Mantiene le cache ma azzera i contatori di conversioni e timing.
	 */
	public void function resetStats(){
		variables.stats = {
			"conversionsCount" = 0,
			"totalTimeMs"      = 0,
			"cacheHits"        = { "metadata" = 0, "rules" = 0 },
			"cacheMisses"      = { "metadata" = 0, "rules" = 0 },
			"startedAt"        = Now()
		};
		// reset per-target stats
		variables.stats["targets"] = {};
	}


	/*
		private methods
	*/

	/**
	 * Build a new memento include/exclude list using the target list and a property root
	 *
	 * @list The list to use for construction
	 * @root The root to filter out
	 *
	 * @return A string list of the new hiearchy to use
	 */
	private function $buildNestedMementoList( required list, required root ){
		/*
		return arguments.list
			.filter( function( target ){
				return ListFirst( arguments.target, "." ) == root && ListLen( arguments.target, "." ) > 1;
			} )
			.map( function( target ){
				return ListDeleteAt( arguments.target, 1, "." );
			} );
		*/

		var results = [];

		for ( var target in arguments.list ) {
			if ( ListFirst( target, "." ) == root && ListLen( target, "." ) > 1 ) {
				results.append( target.listDeleteAt( 1, "." ) );
			}
		}

		return results;
	}

	/**
	 * Build a new memento mappers/defaults struct using the target list and a property root
	 *
	 * @struct The struct to use for construction
	 * @root   The root to filter out
	 *
	 * @return A struct of the new hiearchy to use
	 */
	private function $buildNestedMementoStruct( required struct s, required string root ){
		return arguments.s.reduce( function( acc, key, value ){
			if ( ListFirst( arguments.key, "." ) == root && ListLen( arguments.key, "." ) > 1 ) {
				arguments.acc[ ListDeleteAt( arguments.key, 1, "." ) ] = arguments.value;
			}
			return arguments.acc;
		}, {} );
	}

	/**
	 * Get Deep Properties
	 * Returns an array of an objects properties including those inherited by base classes.
	 *
	 * @metaData (optional) The starting CFML metadata of the entity object. Defaults to the current object.
	 *
	 * @return an array of object properties
	 */
	private array function $getDeepProperties( struct metaData = getCachedMetadata( this ) ){
		var properties = [];

		// if this object extends another object, append any inherited properties.
		if (
			StructKeyExists( arguments.metaData, "extends" ) &&
			StructKeyExists( arguments.metaData.extends, "properties" )
		) {
			properties.append( $getDeepProperties( arguments.metaData.extends ), true );
		}

		// if this object has properties, append them.
		if ( StructKeyExists( arguments.metaData, "properties" ) ) {
			properties.append( arguments.metadata.properties, true );
		}

		return properties;
	}

	private struct function $loadEntityRules( required string entityName ){
		// Controlla la cache: Se già caricato, restituisci immediatamente.
		if ( StructKeyExists( variables.mementoRulesCache, arguments.entityName ) ) {
			variables.stats.cacheHits.rules++;
			return variables.mementoRulesCache[ arguments.entityName ];
		}

		variables.stats.cacheMisses.rules++;

		var rules    = {};
		var filePath = ExpandPath( variables.configDirectory & "/" & arguments.entityName & "Memento.json.cfm" );

		// Controlla se il file esiste
		if ( FileExists( filePath ) ) {
			try {
				var fileContent = FileRead( filePath );
				// Assumiamo che il file JSON contenga direttamente le regole dell'entit�
				rules           = DeserializeJSON( fileContent );
			} catch ( any e ) {
				Throw(
					message = "Config file for entity [#arguments.entityName#] is broken",
					type    = "Mementify.errors.entityRule.ConfigFileNotJson"
				);
			}
		}

		// Salva nella cache (anche se vuoto, per non ricaricarlo)
		variables.mementoRulesCache[ arguments.entityName ] = rules;

		return rules;
	}

	/**
	 * Trova le regole Memento risalendo la gerarchia di ereditariet�.
	 * Questo assicura che un'entità derivata erediti le regole dal suo antenato
	 * se non ha un proprio file di configurazione specifico.
	 * * @targetObject L'istanza dell'oggetto da serializzare.
	 * @return struct La configurazione Memento più specifica trovata (es. ProductMemento.json).
	 */
	private struct function $getRulesFromHierarchy( required Any targetObject ){
		var metadata      = $getCachedMetadata( arguments.targetObject );
		var externalRules = {};

		// Ciclo di risalita della gerarchia: inizia dall'oggetto più specifico
		while ( StructKeyExists( metadata, "fullname" ) ) {
			var entityName = ListLast( metadata.fullname, "." );

			// Carica le regole (usa la cache e legge il file se necessario)
			// Dobbiamo assicuraci che $loadEntityRules sia un metodo esistente nel Mementify
			var currentRules = $loadEntityRules( entityName );

			if ( !StructIsEmpty( currentRules ) ) {
				// Regole trovate! La configurazione più specifica vince.

				externalRules = currentRules;
				break;
			}

			// Passa al genitore
			if ( StructKeyExists( metadata, "extends" ) ) {
				// Usa GetMetaData sul percorso completo della classe genitore
				metadata = metadata.extends;
			} else {
				// Raggiunto l'oggetto base (es. Component, Object)
				break;
			}
		}

		return externalRules;
	}

	/**
	 * Analizza una stringa di configurazione (es. "name:fullName$String") e ne estrae
	 * la proprietà originale, l'alias finale e il tipo di casting richiesto.
	 *
	 * @propertyDefinition La stringa da analizzare.
	 * @return struct Contiene le chiavi 'originalProp', 'finalAlias', 'castType'.
	 */
	private struct function $parsePropertyDefinition( required string propertyDefinition ){
		var definition   = arguments.propertyDefinition;
		var originalProp = "";
		var finalAlias   = "";
		var castType     = "";

		// ESTRAZIONE DEL CASTING ($)
		if ( definition contains "$" ) {
			// Il casting è sempre l'ultima parte
			castType   = ListLast( definition, "$" );
			// Rimuove la parte del casting dalla stringa rimanente
			definition = ListDeleteAt( definition, ListLen( definition, "$" ), "$" );
		}

		// ESTRAZIONE DELL'ALIAS (:)
		if ( definition contains ":" ) {
			// Alias exists: "OriginalProp:FinalAlias"
			originalProp = ListFirst( definition, ":" );
			finalAlias   = ListLast( definition, ":" );
		} else {
			// Nessun alias: OriginalProp è anche l'alias
			originalProp = definition;
			finalAlias   = definition;
		}

		// 3. RESTITUISCE LA STRUTTURA PULITA
		return {
			"prop"     = originalProp,
			"alias"    = finalAlias,
			"castType" = castType
		};
	}


	/**
	 * Applica il casting al valore in base al tipo specificato.
	 *
	 * @value Il valore da convertire.
	 * @castType Il tipo di casting richiesto (es. "String", "Number", "Boolean", "Integer").
	 * @return any Il valore convertito secondo il tipo specificato.
	 */
	private any function $applyCast( required any value, required string castType ){
		// Se non c'è casting richiesto o il valore è null, restituisci il valore
		if ( arguments.castType == "" || IsNull( arguments.value ) ) {
			return arguments.value;
		}

		// Normalizza il nome del tipo (case-insensitive)
		var type = LCase( Trim( arguments.castType ) );

		switch ( type ) {
			case "string":
				return Javacast( "string", arguments.value );
			case "number":
			case "numeric":
			case "double":
			case "float":
				return Javacast( "double", arguments.value );
			case "integer":
			case "int":
			case "long":
				return Javacast( "long", arguments.value );
			case "boolean":
			case "bool":
				return Javacast( "boolean", arguments.value );
			case "array":
				// Se un array, restituiscilo, altrimenti prova a convertirlo
				return IsArray( arguments.value ) ? arguments.value : ListToArray( arguments.value );
			default:
				Throw( message = "CastType [#type#] not found", type = "Mementify.errors.castType.TypeNotFound" );
		}
	}

	/**
	 * Recupera i metadata di un oggetto con caching.
	 * Questa funzione cachea i metadata per evitare chiamate ripetute a GetMetaData()
	 * che sono molto costose in termini di performance.
	 *
	 * @target L'oggetto di cui recuperare i metadata.
	 * @return struct I metadata dell'oggetto (cached se già recuperati in precedenza).
	 */
	private struct function $getCachedMetadata( required any target ){
		// Prima otteniamo il metadata base per avere il fullname

		/*
		if( isNull( arguments.target ) ) {
			dump(arguments.target)
			abort;
		}
		*/

		var metadata = GetMetadata( arguments.target );
		var fullname = metadata.fullname;

		// Se non è in cache, lo aggiungiamo
		if ( !variables.metadataCache.keyExists( fullname ) ) {
			variables.metadataCache[ fullname ] = metadata;
			variables.stats.cacheMisses.metadata++;
		} else {
			variables.stats.cacheHits.metadata++;
		}

		return variables.metadataCache[ fullname ];
	}

}
