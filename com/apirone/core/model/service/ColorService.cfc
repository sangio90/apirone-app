component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ColorDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";

    public com.apirone.core.model.bean.Color function get(
    		required String componentId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.componentId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.componentId );
		cm.put( key, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.Color[] function list(
		String componentId,
	) {
		arguments['limit'] = -1;
		return search(argumentCollection = arguments).getData();
	}

    public com.apirone.core.model.bean.Result function search(
		             String componentId,
			required Numeric limit = 20,
			required Numeric offset = 0
    	){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( componentId = record.clcodice ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }


    /*
    	private method
	*/

	private com.apirone.core.model.bean.Color function build(
    		required String colorId
    	){

	    var record = getDao().read( arguments.colorId );

	    if( record.recordCount ) { 

			var record = trimQueryFields( record );

            var bean = super.bean( "Color" );

            bean.setId( record.clcodice );
			bean.setName( record.cldescri );
			
            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "Color_#arguments.id#";

  	}

}
