component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="cityDao" type="com.apirone.core.model.dao.CityDAO";
	property name="countyDao" type="com.apirone.core.model.dao.CountyDAO";
	property name="countryDao" type="com.apirone.core.model.dao.CountryDAO";
	property name="stateDao" type="com.apirone.core.model.dao.StateDAO";

    public com.apirone.core.model.bean.City function getCity(
    		required String cityId
    	){

    	var cm = getCacheManager();

    	var key = getCacheKey( "City_#arguments.cityId#" );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    }
	    
		var obj = buildCity( arguments.cityId );
		cm.put( key, obj );
        
		return obj;

	}
	
	public com.apirone.core.model.bean.County function getCounty(
    		required String countyId
    	){

    	var cm = getCacheManager();

    	var key = getCacheKey( "County_#arguments.countyId#" );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var obj = buildCounty( arguments.countyId );
		cm.put( key, obj );
        
		return obj;

	}
	
	public com.apirone.core.model.bean.State function getState(
    		required String stateId
    	){

    	var cm = getCacheManager();

    	var key = getCacheKey( "State_#arguments.stateId#" );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var obj = buildState( arguments.stateId );
		cm.put( key, obj );
		
		return obj  

    }

	public com.apirone.core.model.bean.Country function getCountry(
    		required String countryId
    	){

    	var cm = getCacheManager();

    	var key = getCacheKey( "Country_#arguments.countryId#" );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var obj = buildCountry( arguments.countryId );
		cm.put( key, obj );
		return obj  

    }

	public com.apirone.core.model.bean.City function getCity(
    		required String cityId
    	){

    	var cm = getCacheManager();

    	var key = getCacheKey( "City_#arguments.cityId#" );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var obj = buildCity( arguments.cityId );
		cm.put( key, obj );

		return obj  

    }

    public com.apirone.core.model.bean.Result function searchCities(
			required Numeric limit = 50,
			required Numeric offset = 0,
			required Array orderBy = [ { field='city.name' } ],
					String str,
					String countyId,
					String countryId,
					String stateId
    	){

    	var result = super.getResult();
		arguments['orderby'] = super.createOrderBy( arguments['orderby'] );

    	var records = getCityDao().find( argumentCollection=arguments );
		
		var rows = [];

		records.each( function(record) {
	    	rows.push( getCity( cityId = record.city_id ) );
		});
	
	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

	}
	
	
    /**
     * @private
     */
  	private com.apirone.core.model.bean.City function buildCity(
    		required String cityId
    	){

	    var record = getCityDao().read( cityId = arguments.cityId );

	    if( record.RecordCount ) { 

	    	var obj = super.bean( "City" );
            obj.setId( record.city_id.toString() );

			obj.setName( record.city );	
			obj.setCounty( getCounty( countyId = record.county_id ) );
			
			return obj;
			   
	    }

    	return NullValue();

	}

	private com.apirone.core.model.bean.County function buildCounty(
		required String countyId
		){

		var record = getCountyDao().read( countyId = arguments.countyId );

		if( record.RecordCount ) {          

			var obj = super.bean( "County" );
			obj.setId( record.county_id );
			obj.setName( record.county );
			obj.setState( getState( stateId = record.state_id ) );					
			return obj;
		}

		return nullValue();

	}
	  
	private com.apirone.core.model.bean.State function buildState(
    		required String stateId
    	){

		
	    var record = getStateDao().read( stateId = arguments.stateId );

	    if( record.RecordCount ) { 

          	var obj = super.bean( "State" );
            obj.setId( record.state_id.toString() );
			obj.setName( record.state );
			obj.setCountry( getCountry(record.country_id) );
			return obj;
	    }

    	return nullValue();

  	}

	private com.apirone.core.model.bean.Country function buildCountry(
		required String countryId
	){
	
		var record = getCountryDao().read( countryId = arguments.countryId );

		if( record.RecordCount ) { 

			var obj = super.bean( "Country" );
			obj.setId( record.country_id.toString() );
			obj.setName( record.country );
			return obj;
			
		}

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "Geo_#arguments.id#";

  	}

}
