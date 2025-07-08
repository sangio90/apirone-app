component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="com.apirone.core.model.dao.ProductionTimeDAO";
	property name="statusService" inject="com.apirone.core.model.service.StatusService";
	
	property name="cacheScope" type="String" default="productionTime.bean";

    public com.apirone.core.model.bean.ProductionTime function get(
    		required String productionTimeId
        ){

    	var cm = getCacheManager();

   		var cache = cm.get( getCacheScope(), arguments.productionTimeId ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var product = build( arguments.productionTimeId );
		cm.put( getCacheScope(), arguments.productionTimeId, product );

		return product;

	}
        
	public Boolean function codeExists(
		required String code,
		String excludeId =  ""
	){
	
		var products = search( code = arguments.code ).getData();

		return !isNull( products[1] ) AND products[1].getId() NEQ arguments.excludeId 

	}

    public com.apirone.core.model.bean.Result function list(
    	){

        arguments["limit"] = -1;
        return search(argumentCollection = arguments);
   
    }    

    public com.apirone.core.model.bean.Result function search(
			required Numeric limit = 20,
			required Numeric offset = 0,
    	){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( productionTimeId = record.production_time_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }

    /*
    	private method
	*/

	private com.apirone.core.model.bean.ProductionTime function build(
    		required String productionTimeId
    	){

	    var record = getDao().read( arguments.productionTimeId );

	    if( record.recordCount ) { 

            var bean = super.bean( "ProductionTime" );

            bean.setId( record.production_time_id );
			bean.setName( record.production_time );
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setCreatedAt( record.created_at );
			
            return bean;

	    }

		return nullValue();

  	}

}
