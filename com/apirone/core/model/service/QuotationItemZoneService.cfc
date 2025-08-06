component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemZoneDAO";
	property name="QuotationItemService" inject="QuotationItemService";
	property name="QuotationItemZoneService" inject="QuotationItemZoneService";
	property name="cacheScope" type="String" default="QuotationItemZone.bean";

	public com.apirone.core.model.bean.QuotationItemZone function get( required String zoneId ){
		var cm    = getCacheManager();
		var cache = cm.get( getCacheScope(), arguments.zoneId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.zoneId );
		cm.put( getCacheScope(), arguments.zoneId, bean );

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
		required Array orderBy  = [ { field = "quotationItemZone.id" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var rows    = [];
		var result  = super.getResult();
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( zoneId = record.quotation_item_zone_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String zoneId ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.zoneId );

		outcome.setData( { zoneId = arguments.zoneId } );
		getDao().delete( arguments.zoneId );

		transaction {
			try {
				var cm = getCacheManager();
				getDao().delete( arguments.zoneId );
				cm.remove( getCacheScope(), arguments.zoneId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationItemZone" );
				outcome.setMessage( "Cannot delete zone [#arguments.zoneId#]" );
			}
		}
		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.QuotationItemZone zone ){
		var newId = getDao().insert( arguments.zone );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationItemZone zone ){
		getDao().update( arguments.zone );
		super.getCacheManager().remove( getCacheScope(), arguments.zone.getId() );
		
		return arguments.zone.getId();
	}

	private com.apirone.core.model.bean.QuotationItemZone function build( required String zoneId ){
		var record = getDao().read( arguments.zoneId );
		if ( record.recordCount ) {
			var bean = super.bean( "QuotationItemZone" );
			bean.setId( record.quotation_item_zone_id );
			bean.setName( record.quotation_item_zone );
			bean.setQuotationItem( getQuotationItemService().get( record.quotation_item_id ) );

			bean.setParent(
				IsNull( record.parent_id ) ? NullValue() : getQuotationItemZoneService().get( record.parent_id )
			);

			return bean;
		}
		return NullValue();
	}

}
