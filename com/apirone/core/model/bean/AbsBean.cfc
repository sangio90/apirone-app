component accessors="true" {

    property name="id" type="String" default="";
	property name="name" type="String" default="";
    property name="createdAt" type="Date";
    property name="updatedAt" type="Date";

	public Struct function toStruct(){
		
		return DESerializeJSON( SerializeJSON( this ) );
		
	}	

	public String function getShortId(){
		
		return Right( this.getId(), 6 );
		
	}

	public com.apirone.core.model.bean.Lang function getCurrentLang(){
		
		return request.lang;
		
	}

    public Struct function getMainText( langId ){

        if( IsNull( arguments.langId ) ) {

            var langId = getCurrentLang().getId();
        
        } else {
            
            var langId = arguments.langId;
        
        }

        for( var text in getTexts() ) {

            if ( text.getLang().getId() == langId ) {
                return text
            }

        }

        return NullValue();
        
    }


	private Struct function getMetadataObject( required Struct metadata, required String name, String type="properties", Struct result={} ){
		
		var i = 0;
		var k = "";
		
		if( structKeyExists( arguments.metadata, arguments.type ) ){
			
			for( i=1; i<=arraylen( arguments.metadata[ arguments.type ] ); i++ ){
				
            	if( arguments.metadata[ arguments.type ][ i ][ 'name' ] eq arguments.name  ){
					
					arguments.result = arguments.metadata[ arguments.type ][ i ];
					
					return arguments.result;
					
				}
			
			}
			
		}
			
		if( structKeyExists( arguments.metadata, 'extends' ) ){
			
			arguments.result = getMetadataObject( arguments.metadata[ 'extends' ], arguments.name, arguments.type, arguments.result );
				
		}
		
		return arguments.result;
		
	}
	
	public Any function setMemento( required Any data, metaData = getMetaData( this ) ){
		
		var k = "";
		var i = 0;
		var obj = "";
		var class = "";
		var metaObj = {};
		var myArr = createObject('java','java.util.ArrayList').init();
		
		for( k in arguments.data ){
			
			if( structKeyExists( getMetadataObject( metadata, "set#k#", 'functions' ), 'name' )  ){
				
				if( isArray( arguments.data[ k ] ) ){
					
					myArr = createObject('java','java.util.ArrayList').init();
					
					class = rePlaceNoCase( getMetadataObject( metadata, k ).type, "[]", '', 'all' );
					
					if( !listContainsNoCase( 'Struct,Array', class ) ){
					
						for( i=1; i<=arrayLen( arguments.data[ k ] ); i++ ){
						
							obj = createObject( 'component', class ).init();
							
							obj.setMemento( arguments.data[ k ][ i ] );
							
							myArr.add( obj );
							
						}
						
						evaluate( "set#k#( myArr )" );
					
					}else{
						
						evaluate( "set#k#( arguments.data[ k ] )" );
						
					}
					
				}else if( isStruct( arguments.data[ k ] ) ){
					
					class = getMetadataObject( metadata, k ).type;
					
					if( !listContainsNoCase( 'Struct,Array', class ) ){
						
						obj = createObject( 'component', class ).init();
							
						obj.setMemento( arguments.data[ k ] );
						
						evaluate( "set#k#( obj )" );
					
					}else{
						
						evaluate( "set#k#( arguments.data[ k ] )" );
						
					}
					
				}else{
					
					evaluate( "set#k#( arguments.data[ k ] )" );
				
				}
				
				
			}
			
		}
			
	}
	
	public Struct function getMemento( Struct metadata=getMetaData( this ) ){
	
		var memento = {};
		var i = 1;
		var c = 1;
		
		if( StructKeyExists( arguments.metadata, 'extends' ) ){
		
			memento = getMemento( arguments.metadata.extends );
		
		}
		
		if( StructKeyExists( arguments.metadata, 'properties' ) ){
		
			for( i=1; i<=arrayLen( arguments.metadata.properties ); i++ ){
			
				if( REFind("[\+[\+]]", arguments.metadata.properties[i].type ) ){
				
					memento[ arguments.metadata.properties[i].name ] = [];
				
					if( StructKeyExists( variables, arguments.metadata.properties[i].name ) ){
					
						if( ArrayLen( variables[ arguments.metadata.properties[i].name ] ) ){
						
							for( c=1; c<=arrayLen( variables[ arguments.metadata.properties[i].name ] ); c++ ){
							
								if( StructKeyExists( variables[ arguments.metadata.properties[i].name ][c], "getMemento" ) ){
								
									memento[ arguments.metadata.properties[i].name ].add( variables[ arguments.metadata.properties[i].name ][c].getMemento() );
								
								}
							
							}
						
						}
						
					}
					
				
				}else{
				
					if( StructKeyExists( variables, arguments.metadata.properties[i].name ) ){
					
						if( IsObject( variables[ arguments.metadata.properties[i].name ] ) ){
						
							if( StructKeyExists( variables[ arguments.metadata.properties[i].name ], 'getMemento' ) ){
							
								memento[ arguments.metadata.properties[i].name ] = variables[ arguments.metadata.properties[i].name ].getMemento();
							
							
							}else{
							
								memento[ arguments.metadata.properties[i].name ] = variables[ arguments.metadata.properties[i].name ];
							
							}
						
						}else{
						
							memento[ arguments.metadata.properties[i].name ] = variables[ arguments.metadata.properties[i].name ];
						
						}

					}
				
				}
				
			}
		
		}
		
		return memento;		
		
	}

}
