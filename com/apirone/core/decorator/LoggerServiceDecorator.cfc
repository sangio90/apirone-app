component accessors="true" extends="com.apirone.core.decorator.AbsDecorator" {

	property name="wrappedService";
	// property name="logger" inject="AuditLogger";

	public function init( required any wrappedService ){
		setWrappedService( arguments.wrappedService );
		return this;
	}

	public any function onMissingMethod( required String method, required Struct args ){
		var metadata = GetMetadata( wrappedService );
		var logger   = getLogger();


		var result = Invoke(
			wrappedService,
			arguments.method,
			arguments.args
		);

		/**
		 * ATTENZIONE: l'args di onMissingMehod - A VOLTE - non ha come chiave
		 * il nome del metodo della struttura del metodo originale.
		 * https://www.bennadel.com/blog/868-learning-coldfusion-8-onmissingmethod-event-handler.htm
		 * Dovrebbe essere: { "argName1": value1, "argName2": value2 }
		 * Invece è: { "1": value1, "2": value2 }
		 * getNamedArguments() ricostruisce gli argomenti.
		 */
		var namedArgs = getNamedArguments( arguments.method, arguments.args );

		for ( var func in metadata.functions ) {
			if ( func.name == arguments.method ) {
				if ( func.keyExists( "auditEvent" ) ) {
					var params     = { event = func.auditEvent };
					params.payload = NullValue();

					if ( func.keyExists( "auditMessage" ) ) {
						params.message = parseTemplate(
							func[ "auditMessage" ],
							namedArgs,
							result,
							false
						);
					}

					if ( func.keyExists( "auditPayload" ) ) {
						var payloadString = parseTemplate(
							func[ "auditPayload" ],
							namedArgs,
							result,
							false
						);

						if ( IsJSON( payloadString ) ) {
							params.payload = DeserializeJSON( payloadString );
						} else {
							logger.error( "LoggerServiceDecorator: Invalid JSON in auditPayload: #payloadString#" );
						}
					}

					super.logEvent( argumentCollection = params );
				}
				break;
			}
		}

		return result;
	}

	private string function parseTemplate(
		required string template,
		required struct args,
		any result
	){
		var matches = ReMatch( "@[a-zA-Z0-9_.]+@", template );

		for ( var m in matches ) {
			var token    = Replace( m, "@", "", "all" ); // es: return.product.id
			var resolved = resolveToken( token, args, result );
			template     = Replace( template, m, toStringSafe( resolved ), "all" );
		}

		return template;
	}

	function resolveToken( token, args, result ){
		var parts = ListToArray( token, "." );
		var root  = parts[ 1 ];
		var value = "";

		if ( root == "return" ) {
			value = result;
			if ( ArrayLen( parts ) >= 2 ) {
				parts = ArraySlice( parts, 2, ArrayLen( parts ) - 1 );
			} else {
				parts = [];
			}
		} else if ( StructKeyExists( args, root ) ) {
			value = args[ root ];
			if ( ArrayLen( parts ) >= 2 ) {
				parts = ArraySlice( parts, 2, ArrayLen( parts ) - 1 );
			} else {
				parts = [];
			}
		} else if ( root == "args" ) {
			value = args;
			if ( ArrayLen( parts ) >= 2 ) {
				parts = ArraySlice( parts, 2, ArrayLen( parts ) - 1 );
			} else {
				parts = [];
			}
		} else {
			getLogger().error( "LoggerServiceDecorator: Unknown token root: #root#" )
			// WriteDump( "Unknown token root: #root#" );
			return "Unknown token: " & token;
		}

		for ( var i = 1; i <= ArrayLen( parts ); i++ ) {
			if ( IsSimpleValue( value ) ) {
				return serializeValue( value );
			}
			var key = parts[ i ];

			if ( IsObject( value ) ) {
				// prima di chiamare GetMetadata(value).properties, controlliamo che sia struct
				var meta = {};
				try {
					meta = GetMetadata( value );
				} catch ( any e ) {
					// non riusciamo a ottenere metadata? Proseguiamo senza
					meta = {};
				}

				if ( IsStruct( value ) && StructKeyExists( value, key ) ) {
					value = value[ key ];
				} else if (
					IsObject( value ) && StructKeyExists( value, "get" & UCase( Left( key, 1 ) ) & Mid( key, 2 ) )
				) {
					var getter = "get" & UCase( Left( key, 1 ) ) & Mid( key, 2 );
					value      = value[ getter ]( );
				} else if (
					StructKeyExists( meta, "properties" )
					&& IsStruct( meta.properties )
					&& StructKeyExists( meta.properties, key )
				) {
					value = value[ key ];
				} else {
					getLogger().error( "LoggerServiceDecorator: Key not found: #key# in token #token#" )
					return "Key not found: " & token;
				}
			} else if ( IsStruct( value ) ) {
				if ( StructKeyExists( value, key ) ) {
					value = value[ key ];
				} else {
					// WriteDump( "Key not found: #key# in token #token#" );
					getLogger().error( "LoggerServiceDecorator: Key not found: #key# in token #token#" )
					return "Key not found: " & token;
				}
			} else if ( IsArray( value ) ) {
				return serializeValue( value );
			} else {
				return serializeValue( value );
			}
		}
		return serializeValue( value );
	}

	private string function toStringSafe( any val ){
		if ( IsSimpleValue( val ) ) {
			return val & "";
		} else {
			return SerializeJSON( val );
		}
	}

	// Funzione di navigazione generica tra struct/oggetti/getter
	function getNestedValue( value, key ){
		if ( IsStruct( value ) && StructKeyExists( value, key ) ) {
			return value[ key ];
		} else if ( IsObject( value ) && StructKeyExists( value, "get" & key ) ) {
			var getter = "get" & UCase( Left( key, 1 ) ) & Mid( key, 2 );
			return value[ getter ]( );
		} else if ( IsObject( value ) && StructKeyExists( GetMetadata( value ).properties, key ) ) {
			return value[ key ];
		} else {
			return "[Key not found]";
		}
	}

	function isSimpleValue( value ){
		return IsNumeric( arguments.value ) || IsBoolean( arguments.value ) || IsDate( arguments.value ) || (
			isSimpleValueType( arguments.value )
		);
	}

	function isSimpleValueType( value ){
		// stringhe, numeri, boolean, date
		return IsSimpleValue( arguments.value ) || IsNull( arguments.value );
	}

	function serializeValue( value ){
		if ( IsSimpleValue( arguments.value ) ) {
			return arguments.value;
		}
		return SerializeJSON( arguments.value );
	}

	private Struct function getNamedArguments( required string methodName, required struct args ){
		var meta = GetMetadata( getWrappedService() );

		var methodMeta = meta.functions.reduce( ( acc, fn ) => {
			return fn.name == methodName ? fn : acc;
		}, {} );

		var namedArgs    = {};
		var isPositional = true;

		for ( var key in args ) {
			if ( !IsNumeric( key ) ) {
				isPositional = false;
				break;
			}
		}

		// Se sono posizionali, fai il mapping manuale
		if ( isPositional ) {
			var posArgs = arguments.args;
			for ( var i = 1; i <= ArrayLen( methodMeta.parameters ); i++ ) {
				var paramName          = methodMeta.parameters[ i ].name;
				namedArgs[ paramName ] = i <= ArrayLen( posArgs ) ? posArgs[ i ] : Javacast( "null", "" );
			}
		} else {
			// Altrimenti copia direttamente
			namedArgs = Duplicate( args );
		}

		return namedArgs;
	}

}
