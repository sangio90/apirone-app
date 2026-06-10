component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationZonePositionDAO";

	public com.apirone.core.model.bean.QuotationZonePosition function get( required String quotationZonePositionId ){
		return build( arguments.quotationZonePositionId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotationZonePosition.name" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var rows    = [];
		var result  = super.getResult();

		// Il find() ora restituisce tutte le colonne: si possono costruire i bean direttamente
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( buildFromFindRow( record ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required Number quotationZonePositionId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationZonePositionId = arguments.quotationZonePositionId } );

		transaction {
			try {
				getDao().delete( arguments.quotationZonePositionId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.errors.CannotDeleteQuotationZone" );
				outcome.setMessage( "Cannot delete zone [#arguments.quotationZonePositionId#]" );
			}
		}
		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.QuotationZonePosition zonePosition ){
		var newId = getDao().insert( arguments.zonePosition );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationZonePosition zonePosition ){
		getDao().update( arguments.zonePosition );

		return arguments.zonePosition.getId();
	}

	private com.apirone.core.model.bean.QuotationZonePosition function build( required String zoneId ){
		var record = getDao().read( arguments.zoneId );
		if ( record.recordCount ) {

			return buildFromFindRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean QuotationZonePosition a partire da una riga della query.
	 */
	private com.apirone.core.model.bean.QuotationZonePosition function buildFromFindRow( required any record ){
		var bean = super.bean( "QuotationZonePosition" );

		// Campi diretti dal record (QuotationZonePosition non ha sub-entity)
		bean.setId( record.quotation_zone_position_id );
		bean.setCode( record.code );
		bean.setName( record.quotation_zone_position );
		bean.setCreatedAt( record.created_at );
		bean.setZoneId( record.quotation_zone_id.toString() );

		return bean;
	}

}
