component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ProfileDAO";
	property name="GeoService" inject="GeoService";
	property name="LookupService" inject="LookupService";

	public com.apirone.core.model.bean.Profile function get( required String profileId ){
		return build( arguments.profileId );
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

		// Il find() ora restituisce tutte le colonne: si possono costruire i bean direttamente
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID per il caricamento batch
		var ids = [];
		records.each( function( record ){
			ids.append( record.profile_id );
		} );

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.profile_id ] );
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

		transaction {
			try {
				getDao().delete( arguments.profileId );
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

		return arguments.profile.getId();
	}


	/*
    	private method
	*/

	/**
	 * Recupera in batch più Profile dato un array di ID.
	 * Restituisce uno Struct chiave = profileId, valore = bean Profile.
	 * Precarica lookup (profileType) e geo countries in batch per evitare il problema N+1.
	 *
	 * @ids Array di profileId
	 * @return Struct mappato per profileId -> Profile
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie tutti i country_id unici per caricarli in batch
		var countryIds = [];
		for ( var record in records ) {
			if ( !IsNull( record.country_id ) ) {
				countryIds.append( record.country_id );
			}
		}

		// Precarica i Country in batch: raccoglie i countryId unici e li carica.
		var uniqueCountryIds = [];
		for ( var cid in countryIds ) {
			if ( !ArrayContains( uniqueCountryIds, cid ) ) {
				uniqueCountryIds.append( cid );
			}
		}
		var countryMap = {};
		for ( var cid in uniqueCountryIds ) {
			countryMap[ cid ] = getGeoService().getCountry( cid );
		}

		// Cache locale per i lookup (profileType è in-memory via LookupService)
		var types = {};

		for ( var record in records ) {
			// Istanzia il bean corretto in base al tipo
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

			// Campi diretti dal record
			bean.setId( record.profile_id );
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

			// ProfileType: LookupService in-memory, cached localmente
			if ( !StructKeyExists( types, record.type ) ) {
				types[ record.type ] = getLookupService().get( "profileType", record.type );
			}
			bean.setType( types[ record.type ] );

			// Country: dalla mappa pre-caricata
			if ( !IsNull( record.country_id ) && StructKeyExists( countryMap, record.country_id ) ) {
				bean.setCountry( countryMap[ record.country_id ] );
			} else if ( !IsNull( record.country_id ) ) {
				bean.setCountry( getGeoService().getCountry( record.country_id ) );
			}

			map[ record.profile_id ] = bean;
		}

		return map;
	}

	/**
	 * Costruisce un bean Profile a partire dall'ID. Delega a buildFromFindRow() dopo la lettura del record.
	 */
	private com.apirone.core.model.bean.Profile function build(required String profileId) {
    	var record = getDao().read( arguments.profileId );

		if (record.recordCount) {
			return buildFromFindRow( record );
		}

    	return NullValue();
	}

	/**
	 * Costruisce un bean Profile a partire da una riga della query.
	 * Il tipo di bean istanziato (BillingProfile, ShippingProfile, Profile) dipende dal valore di record.type.
	 */
	private com.apirone.core.model.bean.Profile function buildFromFindRow(required any record) {
		// Istanzia il bean corretto in base al tipo
		switch ( record.type ) {
			case "B":
				var bean = super.bean( "BillingProfile" );
				break;
			case "S":
				var bean = super.bean( "ShippingProfile" );
				break;
			case "G": //TODO: ha senso?
				var bean = super.bean( "Profile" );
				break;
			default:
				throw ( "Unknown profile type [#record.type#]" );
		}

		// Campi diretti dal record
		bean.setId( record.profile_id );
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

		// Entity collegate (caricate singolarmente)
		bean.setType( getLookupService().get( "profileType", record.type ) );
		bean.setCountry(
			getGeoService().getCountry( record.country_id )
		);

		return bean;
	}

}
