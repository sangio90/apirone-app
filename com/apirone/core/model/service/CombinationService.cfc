component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.CombinationsDAO";

    public com.apirone.core.model.bean.Combination function get(
    		required String combinationId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.combinationId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.combinationId );
		cm.put( key, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.Combination[] function list() {
		arguments['limit'] = -1;
		
		return search(argumentCollection = arguments).getData();
	
	}


    public com.apirone.core.model.bean.Result function search(
            String lineId
        ){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( combinationId = record.Combination_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.recordcount ) );

        return result;

    }

    public Boolean function delete(
            required Numeric combinationId
        ){

    	var result = getDao().delete( argumentCollection=arguments );

        return result;

    }


    /*
    	private method
	*/

	private com.apirone.core.model.bean.Combination function build(
    		required String combinationId
    	){

	    var record = getDao().read( arguments.combinationId );

	    if( record.recordCount ) { 

            var bean = super.bean( "Combination" );

            bean.setId( record.combination_id );
			bean.setName( "" );
			bean.setCreatedAt( record.created_at );
			//bean.setStatus( getStatusService().get( record.status_id ) );

            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "combination_#arguments.id#";

  	}

}
