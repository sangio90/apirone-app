component extends="com.apirone.core.model.service.AbsService" accessors="true" {

    public com.apirone.core.model.bean.SystemColor function get(
    		required String systemColorId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.systemColorId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.systemColorId );
		cm.put( key, bean );
        
		return bean;

	}


    /*
    	private method
	*/

	private com.apirone.core.model.bean.SystemColor function build(
    		required String systemColorId
    	){

        var colors = DESerializeJSON( FileRead( ExpandPath("/config/data/systemColors.json.cfm") ) );

        for( var color in colors ) {

            if( arguments.systemColorId == color.id ) {

                var bean = super.bean( "SystemColor" );
    
                bean.setId( color.id );
                bean.setName( color.name );
                bean.setClass( color.class );
                bean.setHex( color.hex );
                
                return bean;
    
            }

        }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "SystemColor_#arguments.id#";

  	}

}
