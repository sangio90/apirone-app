component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemPositionDAO";
	property name="QuotationZoneService" inject="QuotationZoneService";
	property name="QuotationItemService" inject="QuotationItemService";
	property name="cacheScope" type="String" default="QuotationItemPosition.bean";

	public com.apirone.core.model.bean.QuotationItemPosition function get( required String positionId ){
		var cm    = getCacheManager();
		var cache = cm.get( getCacheScope(), arguments.positionId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.positionId );
		cm.put( getCacheScope(), arguments.positionId, bean );

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
		required Array orderBy  = [ { field = "quotationItemPosition.id" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var rows    = [];
		var result  = super.getResult();
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( positionId = record.quotation_item_position_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String positionId ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.positionId );

		outcome.setData( { positionId = arguments.positionId } );
		getDao().delete( arguments.positionId );

		transaction {
			try {
				var cm = getCacheManager();
				getDao().delete( arguments.positionId );
				cm.remove( getCacheScope(), arguments.positionId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationItemPosition" );
				outcome.setMessage( "Cannot delete position [#arguments.positionId#]" );
			}
		}
		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.QuotationItemPosition position ){
		var newId = getDao().insert( arguments.position );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationItemPosition position ){
		getDao().update( arguments.position );

		super.getCacheManager().remove( getCacheScope(), arguments.position.getId() );
		return arguments.position.getId();
	}

	private com.apirone.core.model.bean.QuotationItemPosition function build( required String positionId ){
		var record = getDao().read( arguments.positionId );
		if ( record.recordCount ) {
			var bean = super.bean( "QuotationItemPosition" );
			bean.setId( record.quotation_item_position_id );
			bean.setQuotationItemId( record.quotation_item_id );
			bean.setCoordinateX( record.coordinate_x );
			bean.setCoordinateY( record.coordinate_y );
			bean.setVisible( record.visible );
			bean.setAngle( record.angle );
			return bean;
		}
		return NullValue();
	}

}
