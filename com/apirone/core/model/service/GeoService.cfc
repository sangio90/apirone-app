component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="countyDao" inject="CountyDAO";
	property name="countryDao" inject="CountryDAO";
	property name="stateDao" inject="StateDAO";

	property name="cacheScopeCountry" type="String" default="Country.bean";
	property name="cacheScopeCounty" type="String" default="County.bean";
	property name="cacheScopeState" type="String" default="State.bean";

	public com.apirone.core.model.bean.County function getCounty( required String countyId ){
		var cm = getCacheManager();

		var key = getCacheKey( "County_#arguments.countyId#" );

		var cache = cm.get( key );

		if ( cache.status ) {
			return cache.data;
		}

		var obj = buildCounty( arguments.countyId );
		cm.put( key, obj );

		return obj;
	}

	public com.apirone.core.model.bean.State function getState( required String stateId ){
		var cm = getCacheManager();

		var key = getCacheKey( "State_#arguments.stateId#" );

		var cache = cm.get( key );

		if ( cache.status ) {
			return cache.data;
		}

		var obj = buildState( arguments.stateId );
		cm.put( key, obj );

		return obj
	}

	public com.apirone.core.model.bean.Country function getCountry( required String countryId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScopeCountry(), arguments.countryId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = buildCountry( arguments.countryId );
		cm.put( getCacheScopeCountry(), arguments.countryId, bean );

		return bean
	}

	private com.apirone.core.model.bean.County function buildCounty( required String countyId ){
		var record = getCountyDao().read( countyId = arguments.countyId );

		if ( record.RecordCount ) {
			var obj = super.bean( "County" );
			obj.setId( record.county_id );
			obj.setName( record.county );
			obj.setState( getState( stateId = record.state_id ) );
			return obj;
		}

		return NullValue();
	}

	private com.apirone.core.model.bean.State function buildState( required String stateId ){
		var record = getStateDao().read( stateId = arguments.stateId );

		if ( record.RecordCount ) {
			var obj = super.bean( "State" );
			obj.setId( record.state_id.toString() );
			obj.setName( record.state );
			obj.setCountry( getCountry( record.country_id ) );
			return obj;
		}

		return NullValue();
	}

	private com.apirone.core.model.bean.Country function buildCountry( required String countryId ){
		var record = getCountryDao().read( countryId = arguments.countryId );

		if ( record.RecordCount ) {
			var obj = super.bean( "Country" );
			obj.setId( record.country_id.toString() );
			obj.setName( record.country );
			return obj;
		}

		return NullValue();
	}

	private String function getCacheKey( required String id ){
		Throw( "Use cache manager and scope" );
	}

}
