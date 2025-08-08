component accessors="true" {

	property name="id" type="String" default="";
	property name="name" type="String" default="";
	property name="createdAt" type="Date";

	public Struct function toStruct(){
		return DeserializeJSON( SerializeJSON( this ) );
	}

	public String function getShortId(){
		return Right( this.getId(), 5 );
	}

	public Struct function getConfiguration(){
		return new com.apirone.core.model.bean.Configuration();
	}

	public com.apirone.core.model.bean.Lang function getCurrentLang(){
		if ( request.keyExists( "lang" ) ) {
			return request.lang;
		} else {
			var lang = new com.apirone.core.model.bean.Lang();
			lang.setId( "IT" );

			return lang;
		}
	}

	public Struct function getMetadataObject(
		required Struct metadata,
		required String name,
		String type   = "properties",
		Struct result = {}
	){
		var i = 0;
		var k = "";

		if ( StructKeyExists( arguments.metadata, arguments.type ) ) {
			for ( i = 1; i <= ArrayLen( arguments.metadata[ arguments.type ] ); i++ ) {
				if ( arguments.metadata[ arguments.type ][ i ][ "name" ] eq arguments.name ) {
					arguments.result = arguments.metadata[ arguments.type ][ i ];

					return arguments.result;
				}
			}
		}

		if ( StructKeyExists( arguments.metadata, "extends" ) ) {
			arguments.result = getMetadataObject(
				arguments.metadata[ "extends" ],
				arguments.name,
				arguments.type,
				arguments.result
			);
		}

		return arguments.result;
	}

	public Any function setMemento( required Any data, metaData = GetMetadata( this ) ){
		var i       = 0;
		var method  = "";
		var obj     = "";
		var class   = "";
		var metaObj = {};
		var myArr   = CreateObject( "java", "java.util.ArrayList" ).init();

		for ( method in arguments.data ) {
			if ( StructKeyExists( getMetadataObject( metadata, "set#method#", "functions" ), "name" ) ) {
				if ( IsArray( arguments.data[ method ] ) ) {
					myArr = CreateObject( "java", "java.util.ArrayList" ).init();

					class = ReplaceNoCase(
						getMetadataObject( metadata, method ).type,
						"[]",
						"",
						"all"
					);

					if ( !ListContainsNoCase( "Struct,Array", class ) ) {
						for ( i = 1; i <= ArrayLen( arguments.data[ method ] ); i++ ) {
							obj = CreateObject( "component", class ).init();

							obj.setMemento( arguments.data[ method ][ i ] );

							myArr.add( obj );
						}

						Evaluate( "set#method#( myArr )" );
					} else {
						Evaluate( "set#method#( arguments.data[ method ] )" );
					}
				} else if ( IsStruct( arguments.data[ method ] ) ) {
					class = getMetadataObject( metadata, method ).type;

					if ( !ListContainsNoCase( "Struct,Array", class ) ) {
						obj = CreateObject( "component", class ).init();

						obj.setMemento( arguments.data[ method ] );

						Evaluate( "set#method#( obj )" );
					} else {
						Evaluate( "set#method#( arguments.data[ method ] )" );
					}
				} else {
					Evaluate( "set#method#( arguments.data[ method ] )" );
				}
			}
		}
	}

	public Struct function getMemento( Struct metadata = GetMetadata( this ) ){
		var memento = {};
		var i       = 1;
		var c       = 1;

		if ( StructKeyExists( arguments.metadata, "extends" ) ) {
			memento = getMemento( arguments.metadata.extends );
		}

		if ( StructKeyExists( arguments.metadata, "properties" ) ) {
			for ( i = 1; i <= ArrayLen( arguments.metadata.properties ); i++ ) {
				if ( ReFind( "[\+[\+]]", arguments.metadata.properties[ i ].type ) ) {
					memento[ arguments.metadata.properties[ i ].name ] = [];

					if ( StructKeyExists( variables, arguments.metadata.properties[ i ].name ) ) {
						if ( ArrayLen( variables[ arguments.metadata.properties[ i ].name ] ) ) {
							for ( c = 1; c <= ArrayLen( variables[ arguments.metadata.properties[ i ].name ] ); c++ ) {
								if (
									StructKeyExists(
										variables[ arguments.metadata.properties[ i ].name ][ c ],
										"getMemento"
									)
								) {
									memento[ arguments.metadata.properties[ i ].name ].add(
										variables[ arguments.metadata.properties[ i ].name ][ c ].getMemento()
									);
								}
							}
						}
					}
				} else {
					if ( StructKeyExists( variables, arguments.metadata.properties[ i ].name ) ) {
						if ( IsObject( variables[ arguments.metadata.properties[ i ].name ] ) ) {
							if (
								StructKeyExists(
									variables[ arguments.metadata.properties[ i ].name ],
									"getMemento"
								)
							) {
								memento[ arguments.metadata.properties[ i ].name ] = variables[
									arguments.metadata.properties[ i ].name
								].getMemento();
							} else {
								memento[ arguments.metadata.properties[ i ].name ] = variables[
									arguments.metadata.properties[ i ].name
								];
							}
						} else {
							memento[ arguments.metadata.properties[ i ].name ] = variables[
								arguments.metadata.properties[ i ].name
							];
						}
					}
				}
			}
		}

		return memento;
	}

}
