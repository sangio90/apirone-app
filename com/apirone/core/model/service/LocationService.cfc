component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="LocationDAO";
	property name="geoService" inject="GeoService";

	public com.apirone.core.model.bean.Location function get( required String locationId ){
		return build( arguments.locationId );
	}

	public String function update( required com.apirone.core.model.bean.Location location ){
		return getDao().update( location = arguments.location );
	}

	public String function create(
		required com.apirone.core.model.bean.Location location,
		required com.apirone.core.model.bean.Entity entity
	){
		return getDao().insert( location = arguments.location, entity = arguments.entity );
	}

	public com.apirone.core.model.bean.Result function list( String companyId, String employeeId ){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments )
	}


	public com.apirone.core.model.bean.Result function search(
		required Numeric limit  = 20,
		required Numeric offset = 0,
		String companyId,
		String employeeId
	){
		var rows   = [];
		var result = super.getResult();

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i bean in blocco con getMany()
		var ids = [];
		records.each( function( r ){
			ids.append( r.location_id );
		} );

		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.location_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/**
	 * Recupera in batch più Location dato un array di ID.
	 * Restituisce uno Struct chiave = locationId, valore = bean Location.
	 * Precarica le città (GeoService) in batch locale per evitare il problema N+1.
	 *
	 * @ids Array di locationId
	 * @return Struct mappato per locationId -> Location
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};
		var cities  = {};

		for ( var record in records ) {
			var location = super.bean( "Location" );

			// Campi diretti dal record
			location.setId( record.location_id.toString() );
			location.setAddress( record.address );
			location.setPostalCode( record.postal_code );

			// Città: cached localmente (GeoService)
			if ( !StructKeyExists( cities, record.city_id ) ) {
				cities[ record.city_id ] = getGeoService().getCity( cityId = record.city_id );
			}
			location.setCity( cities[ record.city_id ] );

			map[ location.getId() ] = location;
		}

		return map;
	}


	/**
	 * @private
	 */
	private com.apirone.core.model.bean.Location function build( required String locationId ){
		var record = getDao().read( locationId = arguments.locationId );

		if ( record.RecordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Location a partire da una riga della query.
	 * Utilizzato sia da build() (record singolo) che da search() (iterazione batch).
	 */
	private com.apirone.core.model.bean.Location function buildFromRow( required any row ){
		var location = super.bean( "Location" );

		// Campi diretti dal record
		location.setId( arguments.row.location_id.toString() );
		location.setAddress( arguments.row.address );
		location.setPostalCode( arguments.row.postal_code );

		// Entity collegata (GeoService, caricata singolarmente)
		location.setCity( getGeoService().getCity( cityId = arguments.row.city_id ) );

		return location;
	}

}
