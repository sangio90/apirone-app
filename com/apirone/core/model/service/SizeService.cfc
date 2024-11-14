component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.SizeDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";

    public com.apirone.core.model.bean.Size function get(
    		required String sizeId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.sizeId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.sizeId );
		cm.put( key, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.Size[] function list(
		String lineId,
	) {
		arguments["limit"] = -1;
		return search(argumentCollection = arguments).getData();
	}

    public com.apirone.core.model.bean.Result function search(
		             String lineId,
			required Numeric limit = 20,
			required Numeric offset = 0
    	){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function( record ) {
			rows.add( get( sizeId = record.size_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }


    /*
    	private method
	*/

	private com.apirone.core.model.bean.Size function build(
    		required String sizeId
    	){

	    var record = getDao().read( arguments.sizeId );

	    if( record.recordCount ) { 

			var record = trimQueryFields( record );

            var bean = super.bean( "Size" );

            bean.setId( record.size_id );
			bean.setName( record.size );
			bean.setFruitsCount( record.fruits_count );
			
            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "Size_#arguments.id#";

  	}

}
