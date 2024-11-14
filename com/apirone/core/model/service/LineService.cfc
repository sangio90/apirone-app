component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.LineDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="lookupService" type="com.apirone.core.model.service.LookupService";
	property name="LineCategoryService" type="com.apirone.core.model.service.LineCategoryService";

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
		arguments["limit"] = -1;
		
		return search(argumentCollection = arguments).getData();
	
	}


    public com.apirone.core.model.bean.Result function search(){
	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( lineId = record.line_id ) );
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

            var bean = super.bean( "Line" );

            bean.setId( record.line_id );
			bean.setName( record.line );
			bean.setCreatedAt( record.created_at );
			bean.setThickness( getLookupService().get( "thickness", record.thickness_id ) );
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setCategory( getLineCategoryService().get( record.line_category_id ) );

            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "line_#arguments.id#";

  	}

}
