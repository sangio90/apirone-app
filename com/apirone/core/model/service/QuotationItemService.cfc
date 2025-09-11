component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemDAO";
	property name="QuotationService" inject="QuotationService";
	property name="QuotationZoneService" inject="QuotationZoneService";
	property name="cacheScope" type="String" default="QuotationItem.bean";

	public com.apirone.core.model.bean.QuotationItem function get( required String quotationItemId ){
		var cm    = getCacheManager();
		var cache = cm.get( getCacheScope(), arguments.quotationItemId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.quotationItemId );

		cm.put(
			getCacheScope(),
			arguments.quotationItemId,
			bean
		);

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
		required Array orderBy  = [ { field = "quotation.id" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );
		var rows               = [];
		var result             = super.getResult();
		var records            = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( quotationItemId = record.quotation_item_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String quotationItemId ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.quotationItemId );

		outcome.setData( { quotationItemId = arguments.quotationItemId } );
		getDao().delete( arguments.quotationItemId );

		transaction {
			try {
				var cm = getCacheManager();
				getDao().delete( arguments.quotationItemId );
				cm.remove( getCacheScope(), arguments.quotationItemId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationItem" );
				outcome.setMessage( "Cannot delete quotation item [#arguments.quotationItemId#]" );
			}
		}

		return outcome;
	}

	public String function create( required quotationItem ){
		var newId = getDao().insert( arguments.quotationItem );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationItem quotationItem ){
		getDao().update( arguments.quotationItem );
		super.getCacheManager().remove( getCacheScope(), arguments.quotationItem.getId() );

		return arguments.quotationItem.getId();
	}

	private com.apirone.core.model.bean.QuotationItem function build( required String quotationItemId ){
		var record = getDao().read( arguments.quotationItemId );

		if ( record.recordCount ) {
			var bean = super.bean( "QuotationItem" );

			bean.setId( record.quotation_item_id );
			bean.setPrice( record.price );
			bean.setQuantity( record.quantity );
			bean.setQuotation( getQuotationService().get( record.quotation_id ) );
			bean.setQuotationZone(
				IsNull( record.quotation_zone_id ) ? NullValue() : getQuotationZoneService().get(
					record.quotation_zone_id
				)
			);

			return bean;
		}
		return NullValue();
	}

}
