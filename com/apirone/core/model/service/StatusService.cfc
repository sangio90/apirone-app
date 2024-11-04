component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.StatusDAO";
	property name="systemColorService" type="com.apirone.core.model.service.systemColorService";

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

    public com.apirone.core.model.bean.Status[] function list(
			required String entityId
    	){

	    var rows = [];

		var records = getDao().find( argumentCollection=arguments );

		records.each( function( record ) {
			rows.add( get( record.status_id ) );
		});

        return rows;

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
			obj.setColor( getSystemColorService().get( record.color_id ) );

			return obj;
			
	    }

    	return NullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "Status_#arguments.id#";

  	}

}
