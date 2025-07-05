component extends="com.apirone.core.model.service.AbsService" name="i18nService" accessors="true" singleton {

    property name="cacheScope" type="String" default="i18n.bean";

	public String function get(
		required String key,
		required String langId="it",
	){
        var result = "";

    	var cm = getCacheManager();

	   	var cache = cm.get( getCacheScope(), arguments.toString() ) ;

        if ( cache.status ) {

            result = cache.data;

        } else {
            
            var rows = DeserializeJSON( FileRead( ExpandPath('/config/data/i18n/#arguments.langId#.json.cfm') ) );

            for ( var row in rows )  {

                if( arguments.key == row.id ) {
                    result = row.name
                }
    
            }

            cm.put( getCacheScope(), arguments.toString(), result ) ;

        }

        return result;

	}    
    public Struct function list(
		required String langId,
		         Boolean forJS
	){
        var result = [];

    	var cm = getCacheManager();

        var cacheKey = arguments.toString();

	   	var cache = cm.get( getCasceScope(), arguments.toString() ) ;

        if ( cache.status ) {

            result = cache.data;

        } else {

            var rows = DeserializeJSON( FileRead( ExpandPath('/config/data/i18n/#langId#.json.cfm') ) );

            for ( var row in rows )  {

                if ( !IsNull( arguments.forJs ) ) {

                    if ( row.js == arguments.forJs ) {

                        result.add( build( row ) );

                    }

                } else {

                    result.add( build( row ) );
    
                }

            }

            result = convert( result );

            cm.put( getCasceScope() , arguments.toString(), result ) ;

        }

        return result;

	}

  	private com.apirone.core.model.bean.I18nText function build( required Struct data ) {

  		return getFactory().createInstance( "I18nText", data )

  	}

  	private Struct function convert( required Array rows ) {

        var result = {};

        for ( var row in rows ) {

            result[ row.getId() ] = row.getName();
            
        }

        return result;

    }

}
