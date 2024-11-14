component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.LocationDAO";
	property name="geoService" type="com.apirone.core.model.service.GeoService";

	public com.apirone.core.model.bean.Location function get(
			required String locationId
    	){

			var cm = getCacheManager();

			var key = getCacheKey( arguments.locationId );
	
			   var cache = cm.get( key ) ;
	
			if ( cache.status ) {
			
				  return cache.data;
			
			}
			
			var location = build( arguments.locationId );
			cm.put( key, location );
			return location;

	} 
    
    public String function update(
            required com.apirone.core.model.bean.Location location
		){		

		var id =  getDao().update( 
                location = arguments.location
            );

		getCacheManager()
			.remove( getCachekey( id ) );

		return id;
	}

    public String function create(
        required com.apirone.core.model.bean.Location location,
        required com.apirone.core.model.bean.Entity entity,
    ){		

        return getDao().insert( 
                location = arguments.location,
                entity = arguments.entity
            );
    }

    public com.apirone.core.model.bean.Result function list(
		String companyId,
		String employeeId
	) {
		arguments["limit"] = -1;
		return search(argumentCollection = arguments)
	}


    public com.apirone.core.model.bean.Result function search(
			required Numeric limit = 20,
			required Numeric offset = 0,
			String companyId,
			String employeeId
    	){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( locationId = record.location_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }

    
    /**
     * @private
     */
    private com.apirone.core.model.bean.Location function build(
		required String locationId
	){

		var record = getDao().read( locationId = arguments.locationId );

		if( record.RecordCount ) { 
			
			var location = super.bean( "Location" );
			location.setId( record.location_id.toString() );
			location.setAddress( record.address );	
			location.setPostalCode( record.postal_code );

			location.setCity( getGeoService().getCity( cityId = record.city_id ) );
			
			return location;
			
		}

		return NullValue();

	}
	  
  	private String function getCacheKey( required String id ) {

  		return "Location_#arguments.id#";

  	}

}
