component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ColorDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";

    public com.apirone.core.model.bean.Color function get(
    		required String colorId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.colorId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.colorId );
		cm.put( key, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.Color[] function list(
			String rawProductId,
	) {
		arguments["limit"] = -1;
		return search(argumentCollection = arguments).getData();
	}

    public com.apirone.core.model.bean.Result function search(
		             String rawProductId,
			required Numeric limit = 20,
			required Numeric offset = 0
    	){

		//cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# colorService:search()");

		var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# colorService:search();recordCount:#records.recordCount#;rawProductId:'#arguments.rawProductId#'");

		records.each(function( record, index ) {

			cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# colorService:search();index:#index#;clcodice:'#record.clcodice#'");

			rows.add( get( colorId = record.clcodice ) );
		
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordCount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }


    /*
    	private method
	*/

	private com.apirone.core.model.bean.Color function build(
    		required String colorId
    	){

        var bean = super.bean( "Color" );

		if( arguments.colorId == "_NOCOL" ) {
	
			bean.setId("_NOCOL");
			bean.setName("Nessun colore");

			return bean;

		}
	
	    var record = getDao().read( arguments.colorId );

	    if( record.recordCount ) { 

			var record = trimQueryFields( record );

            bean.setId( record.clcodice );
			bean.setName( record.cldescri );
			
            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

		cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# colorService:getCacheKey();colorId:'#arguments.id#'");

		return "Color_#Hash(arguments.id)#";

  	}

}
