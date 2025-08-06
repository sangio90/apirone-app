component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemPositionDAO";
	property name="QuotationItemZoneService" inject="QuotationItemZoneService";
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

		transaction {
			for ( var text in arguments.position.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "quotationItemPosition.id" );
				entity.setValue( newId );

				text.setEntity( entity );
			}

			getTextService().bulkCreate( arguments.position.getTexts() );
		}
		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationItemPosition position ){
		getDao().update( arguments.position );

		var id = arguments.line.getId();

		for ( var text in arguments.position.getTexts() ) {
			var entity = super.bean( "Entity" )

			entity.setKey( "quotationItemPosition.id" );
			entity.setValue( id );

			text.setEntity( entity );

			if ( Len( text.getId() ) ) {
				getTextService().update( text );
			} else {
				getTextService().create( text );
			}
		}

		super.getCacheManager().remove( getCacheScope(), arguments.position.getId() );
		return arguments.position.getId();
	}

	private com.apirone.core.model.bean.QuotationItemPosition function build( required String positionId ){
		var record = getDao().read( arguments.positionId );
		if ( record.recordCount ) {
			var bean = super.bean( "QuotationItemPosition" );
			bean.setId( record.quotation_item_position_id );
			bean.setQuotationItemZone( getQuotationItemZoneService().get( record.quotation_item_zone_id ) );
			bean.setPositionCoordinateX( record.position_coordinate_x );
			bean.setPositionCoordinateY( record.position_coordinate_y );
			bean.setTexts( getTextService().list( positionId = record.quotation_item_position_id ) );
			return bean;
		}
		return NullValue();
	}

}
