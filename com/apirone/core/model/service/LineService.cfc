component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.LineDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";

    public com.apirone.core.model.bean.Line function get(
    		required String lineId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.lineId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.lineId );
		cm.put( key, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.Line[] function list() {
		arguments['limit'] = -1;
		
		return search(argumentCollection = arguments).getData();
	
	}


    public com.apirone.core.model.bean.Result function search(){
	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( lineId = record.codlin ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.recordcount ) );

        return result;

    }


    /*
    	private method
	*/

	private com.apirone.core.model.bean.Line function build(
    		required String lineId
    	){

	    var record = getDao().read( arguments.lineId );

	    if( record.recordCount ) { 

			var record = trimQueryFields( record );

            var bean = super.bean( "Line" );

            bean.setId( record.codlin );
			bean.setName( record.deslin );

            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "Line_#arguments.id#";

  	}

}
