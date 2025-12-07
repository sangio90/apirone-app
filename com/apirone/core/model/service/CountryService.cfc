component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="CountryDAO";
	property name="textService" inject="TextService";
	property name="cacheScope" type="String" default="Country.bean";

	public com.apirone.core.model.bean.Country function get( required String countryId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.countryId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.countryId );
		cm.put( getCacheScope(), arguments.countryId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	/*
    	private method
	*/

	private com.apirone.core.model.bean.Country function build( required String countryId ){
		var record = getDao().read( arguments.countryId & "x" );

		if ( record.recordCount ) {

			var bean = super.bean( "Country" );
			var record = super.trimQueryFields( record );

			bean.setIsoCode( record.ISONAZ );
			bean.setCode( record.CODNAZ );
			bean.setName( record.DESNAZ );
			
			return bean;
		}

		if( IsNull( country ) ) {
			getLogger().error( "CountryService. Country code [#countryId#] not found from Verticale." );
		}

		return NullValue();
	}

}
