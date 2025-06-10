component accessors="true"{

    public Struct function get(
            required String key
        ){

        var ret.status = false;

        var exists = CacheIdExists( arguments.key );

        if( exists ) {
            ret = {
                data   = CacheGet( arguments.key ),
                status = true
            }
        }

        return ret;

    }

    public Void function put(
            required String key,
            required Any value
        ){

        if ( !isNull( arguments.value ) ) {

            CachePut( arguments.key, arguments.value );

        }

    }

    public Void function remove(
            required String key
        ){

        CacheRemove( arguments.key );

    }

    public Void function removeAll() {

        CacheRemoveAll();

    }

    public Struct function list() {

        return CacheGetAll();

    }

}
