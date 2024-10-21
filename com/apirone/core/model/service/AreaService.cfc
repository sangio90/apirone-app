component extends="com.wineshipping.core.model.service.AbsService" accessors="true" {

    property name="dao" type="com.wineshipping.core.model.dao.AreaDAO";

    public com.wineshipping.core.model.bean.Area function get(
    		required String areaId
    	){

	
    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.areaId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
		
		}
	    
		var account = build( arguments.areaId );
		
		if ( !IsNull( account ) ) {
			cm.put( key, account );
		}	    
		
        return account;

	}

    public com.wineshipping.core.model.bean.Result function list(){
		arguments['limit'] = -1;
		return search(argumentCollection = arguments)
    }


    public com.wineshipping.core.model.bean.Result function search(
			required Numeric limit = 20,
			required Numeric offset = 0,
			required Array orderby= [ {"field" = "orderby"} ],
            		 String shipmentId
    	){

		var thisOrderby = createOrderBy( arguments.orderby );
		arguments["orderby"] = thisOrderby;
	
	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function( record ) {
			rows.add( get( record.area_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }	

	public String function update(
			required com.wineshipping.core.model.bean.Area area
		){

		if ( !Len( arguments.area.getId() ) ) {
			throw( type="WineShipping.errors.AreaIdNotProvided", message="Id required" );
		};
	
		if ( !Len( arguments.area.getName() ) ) {
			throw( type="WineShipping.errors.AreaNameNotProvided", message="Name required" );
		};

		var id = getDao().update( arguments.area );

		getCacheManager().remove( getCacheKey( arguments.area.getId() ) );

		return id;

	}


    /**
     * @private
     */	

  	private com.wineshipping.core.model.bean.Area function build(
    		required String areaId
    	){

	    var record = getDao().read( areaId = arguments.areaId );
		
	    if( record.RecordCount ) { 

	    	var account = super.bean( "Area" );

		    account.setId( record.area_id );
			account.setName( record.area );
		    account.setMessage( record.message );
		    account.setCreated( now() );

			return account;

	    } 
			
		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "area_#arguments.id#";

  	}

}
