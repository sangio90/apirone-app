component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.StatusDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";

    public com.apirone.core.model.bean.Status function get(
    		required String statusId
        ){

    	var cm = super.getCacheManager();

    	var key = getCacheKey( arguments.statusId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var obj = build( arguments.statusId );
		
		cm.put( key, obj );
        
		return obj;

	}

    public com.apirone.core.model.bean.Result function list(
			required String entityId
    	){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each( function( record ) {
			rows.add( get( record.status_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }	

    /*
    	private method
	*/

	private com.apirone.core.model.bean.Status function build(
    		required String statusId
    	){

	    var record = getDao().read( arguments.statusId );

	    if( record.RecordCount ) { 

          	var obj = super.bean( "Status" );

            obj.setId( record.status_id );
			obj.setName( record.status );

			return obj;
			
	    }

    	return NullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "Status_#arguments.id#";

  	}

}
