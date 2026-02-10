component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationZonePositionDAO";
	property name="QuotationZoneService" inject="QuotationZoneService";
	property name="cacheScope" type="String" default="QuotationZonePosition.bean";

	public com.apirone.core.model.bean.QuotationZonePosition function get( required String quotationZonePositionId ){
		var cm    = getCacheManager();
		var cache = cm.get( getCacheScope(), arguments.quotationZonePositionId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.quotationZonePositionId );
		cm.put( getCacheScope(), arguments.quotationZonePositionId, bean );
		return bean;
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
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( quotationZonePositionId = record.quotation_zone_position_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String quotationZonePositionId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationZonePositionId = arguments.quotationZonePositionId } );
		
		var cm = getCacheManager();
		
		transaction {
			try {
				getDao().delete( arguments.quotationZonePositionId );
				cm.remove( getCacheScope(), arguments.quotationZonePositionId );
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
		super.getCacheManager().remove( getCacheScope(), arguments.zonePosition.getId() );

		return arguments.zonePosition.getId();
	}

	private com.apirone.core.model.bean.QuotationZonePosition function build( required String zoneId ){
		var record = getDao().read( arguments.zoneId );
		if ( record.recordCount ) {

			var bean = super.bean( "QuotationZonePosition" );

			bean.setId( record.quotation_zone_position_id );
			bean.setCode( record.code );
			bean.setName( record.quotation_zone_position );
			bean.setCreatedAt( record.created_at );
			bean.setZoneId( record.quotation_zone_id.toString() );

			return bean;
		}

		return NullValue();
	}

}
