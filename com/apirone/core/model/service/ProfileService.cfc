component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ProfileDAO";
	property name="GeoService" inject="GeoService";
	property name="LookupService" inject="LookupService";
	property name="cacheScope" type="String" default="Profile.bean";

	public com.apirone.core.model.bean.Profile function get( required String profileId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.profileId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.profileId );
		cm.put( getCacheScope(), arguments.profileId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit    = 15,
		required Numeric offset   = 0,
		required Array orderBy    = [ { field = "profile.id" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( profileId = record.profile_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String profileId ){
		var outcome = super.bean( "Outcome" );
		var obj = get( arguments.profileId );
		
		outcome.setData( { profileId = arguments.profileId } );
		getDao().delete( arguments.profileId );

		transaction {
			try {
				var cm = getCacheManager();

				getDao().delete( arguments.profileId );

				cm.remove( getCacheScope(), arguments.profileId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteProfile" );
				outcome.setMessage( "Cannot delete profile [#arguments.profileId#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.Profile profile ){
		var newId = getDao().insert( arguments.profile );

		return newId;
	}


	public String function update( required com.apirone.core.model.bean.Profile profile ){
		getDao().update( arguments.profile );

		super.getCacheManager().remove( getCacheScope(), arguments.profile.getId() );

		return arguments.profile.getId();
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.Profile function build(required String profileId) {
    	var record = getDao().read( arguments.profileId );

		if (record.recordCount) {
			switch ( record.type ) {
				case "B":
					var bean = super.bean( "BillingProfile" );
					break;
				case "S":
					var bean = super.bean( "ShippingProfile" );
					break;
				case "G":
					var bean = super.bean( "Profile" );
					break;
				default:
					throw ( "Unknown profile type [#record.type#]" );
			}
			
			bean.setId( record.profile_id );
			bean.setType( getLookupService().get( "profileType", record.type ) );
			bean.setFirstName( record.first_name );
			bean.setLastName( record.last_name );
			bean.setCompany( record.company );
			bean.setVatNumber( record.vat_number );
			bean.setEmail( record.email );
			bean.setPhone( record.phone );
			bean.setState( record.state );
			bean.setCity( record.city );
			bean.setPostalCode( record.postal_code );
			bean.setStreet( record.street );
			bean.setCreatedAt( record.created_at );

			bean.setCountry(
				getGeoService().getCountry( record.country_id )
			);

			return bean;
		}

    	return NullValue();
	}

}
