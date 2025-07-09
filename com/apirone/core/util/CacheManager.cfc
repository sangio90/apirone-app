component accessors="true"{

    property name="scopes" type="Struct";

    public CacheManager function init( required Struct scopes ){

        setScopes( arguments.scopes );

        return this;

    }    

    public Struct function get(
            required String scope, 
            required Any key
        ){

        var cacheKey = createCacheKey( arguments.scope, arguments.key );
        var ret = {};
        
        ret.status = false;

        var exists = CacheIdExists( cacheKey );

        if( exists ) {
            ret = {
                data   = CacheGet( cacheKey ),
                status = true
            }
        }
        
        return ret;

    }

    public Void function put(
            required String scope,
            required Any key,
            required Any value
        ){

        var cacheKey = createCacheKey( arguments.scope, arguments.key)

        CachePut( cacheKey, arguments.value );

    }


    public Void function remove(
            required String scope,
            required Any key
        ){

        CacheRemove( 
            createCacheKey( arguments.scope, arguments.key) 
        );

    }

    public Void function removeByScope(
            required String scope,
        ){

        if( !scopeExists( arguments.scope ) ) {
            throw( message = "The scope [#arguments.scope#] not exists.", type = "CacheManager.Errors.ScopeNotExists" );
        }

        var keys = CacheGetAllIds();

        for( var cacheKey in keys ) {

            if ( left( cacheKey, len( arguments.scope ) + 1 ) == "#arguments.scope#_" ) {

                CacheRemove( cacheKey );

            }

        }

    }
    

    public Void function removeAll() {

        CacheRemoveAll();

    }

    public Struct function list() {

        return CacheGetAll();

    }

    private Boolean function scopeExists( required String scope ) {

        return getScopes().keyExists( arguments.scope );

	}


    private String function createCacheKey( required String scope, required Any key ) {

        if ( !scopeExists( arguments.scope ) ) {
            throw( message = "The scope [#arguments.scope#] not exists. Add it to configuration.", type = "CacheManager.Errors.ScopeNotExists" );
        }

        var thisKey = IsSimpleValue( arguments.key ) ? arguments.key : arguments.key.toString();

		return "#arguments.scope#_#Hash( thisKey )#"
	}


}
