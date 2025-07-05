component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="scopeCache" type="String" default="SystemColor.bean";

    public com.apirone.core.model.bean.SystemColor function get(
    		required String systemColorId
        ){

    	var cm = getCacheManager();

	   	var cache = cm.get( getScopeCache(), arguments.systemColorId ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.systemColorId );
		cm.put( getScopeCache(), arguments.systemColorId, bean );
        
		return bean;

	}


    public com.apirone.core.model.bean.SystemColor[] function list(
    		required String systemColorId
        ){

		var rows = [];

        var colors = this.find();

        for( var color in colors ) {

			rows.add( get( systemColorId = color.id ) );

        }
        
		return rows;

	}


    /*
    	private method
	*/

	private com.apirone.core.model.bean.SystemColor function build(
    		required String systemColorId
    	){

        var colors = this.find();

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

	private Array function find(){

        var colors = DESerializeJSON( FileRead( ExpandPath("/config/data/systemColors.json.cfm") ) );

		return colors;

  	}

}
