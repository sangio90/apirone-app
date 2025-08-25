/*
	Thanks to:
	https://github.com/coldbox-modules/mementifier
*/

component {

	variables.settings = {};

	function init( required settings = {} ){
		var thisSettings = {
			iso8601Format     = settings?.iso8601Format ?: false,
			dateMask          = settings?.dateMask ?: "yyyy-MM-dd",
			timeMask          = settings?.timeMask ?: "HH:mm:ss",
			nullDefaultValue  = settings?.nullDefaultValue ?: null,
			trustedGetters    = settings?.trustedGetters ?: false,
			convertToTimezone = settings?.convertToTimezone ?: "",
			autoCastBooleans  = settings?.autoCastBooleans ?: false
		}

		variables.settings = thisSettings;

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
	 * @defaults         A struct of key-value pairs that denotes the default values for properties if they are null, defaults for everything are a blank string.
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
		var target = Duplicate( arguments.target );


		local.includes = Duplicate( arguments.includes );
		local.excludes = Duplicate( arguments.excludes );

		var memento = arguments.target.memento;

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

			// Retrieve Value for transformation: ACF Incompats Suck on elvis operator
			var thisValue = Javacast( "null", "" );
			// Do we have a property output alias?
			if ( item.find( ":" ) ) {
				var thisAlias = item.getToken( 2, ":" );
				item          = item.getToken( 1, ":" );
			} else {
				var thisAlias = item;
			}

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
						result[ thisAlias ] = Trim(
							DateFormat( dateInstance, arguments.dateMask ) & " " & timeFormat
						);
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
					// only get mementos from relationships that have mementos, in the event that we have an already-serialized array of structs
					if (
						!IsSimpleValue( thisValue[ thisIndex ] ) && StructKeyExists(
							thisValue[ thisIndex ],
							"memento"
						)
					) {
						// If no nested includes requested, then default them
						var nestedIncludes = $buildNestedMementoList( includes, item );

						// Process the item memento
						result[ thisAlias ][ thisIndex ] = convert(
							target          : thisValue[ thisIndex ],
							includes        : nestedIncludes,
							excludes        : $buildNestedMementoList( excludes, item ),
							mappers         : $buildNestedMementoStruct( mappers, item ),
							defaults        : $buildNestedMementoStruct( defaults, item ),
							// cascade the ignore defaults down if specific nested includes are requested
							ignoreDefaults  : nestedIncludes.len() ? arguments.ignoreDefaults : false,
							// Cascade the arguments to the children
							profile         : arguments.profile,
							trustedGetters  : arguments.trustedGetters,
							iso8601Format   : arguments.iso8601Format,
							dateMask        : arguments.dateMask,
							timeMask        : arguments.timeMask,
							autoCastBooleans: arguments.autoCastBooleans
						);
					} else {
						result[ thisAlias ][ thisIndex ] = thisValue[ thisIndex ];
					}
				}
			}

			// Single Object Relationships
			else if ( IsValid( "component", thisValue ) && IsDefined( "thisValue.memento" ) ) {
				// If no nested includes requested, then default them
				var nestedIncludes = $buildNestedMementoList( includes, item );

				// Process the item memento
				var thisItemMemento = convert(
					target          : thisValue,
					includes        : nestedIncludes,
					excludes        : $buildNestedMementoList( excludes, item ),
					mappers         : $buildNestedMementoStruct( mappers, item ),
					defaults        : $buildNestedMementoStruct( defaults, item ),
					// cascade the ignore defaults down if specific nested includes are requested
					ignoreDefaults  : nestedIncludes.len() ? arguments.ignoreDefaults : false,
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
		}

		for ( var item in result ) {
			// Do we have a mapper according to this key?
			if ( mappersKeyArray.findNoCase( item ) ) {
				// ACF compat
				var thisMapper = thisMemento.mappers[ item ];
				// Transform it
				result[ item ] = thisMapper( result[ item ], result );
			} else {
				// Check for null values
				result[ item ] = ( !result.keyExists( item ) || IsNull( result[ item ] ) ) ? Javacast( "null", "" ) : result[
					item
				];
			}
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
	 * Build a new memento include/exclude list using the target list and a property root
	 *
	 * @list The list to use for construction
	 * @root The root to filter out
	 *
	 * @return A string list of the new hiearchy to use
	 */
	private function $buildNestedMementoList( required list, required root ){
		return arguments.list
			.filter( function( target ){
				return ListFirst( arguments.target, "." ) == root && ListLen( arguments.target, "." ) > 1;
			} )
			.map( function( target ){
				return ListDeleteAt( arguments.target, 1, "." );
			} );
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
	private array function $getDeepProperties( struct metaData = GetMetadata( this ) ){
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

}
