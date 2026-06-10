component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemPositionDAO";

	public com.apirone.core.model.bean.QuotationItemPosition function get( required String positionId ){
		return build( arguments.positionId );
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

	public com.apirone.core.model.bean.Outcome function delete( required String positionId ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.positionId );

		outcome.setData( { positionId = arguments.positionId } );

		transaction {
			try {
				getDao().delete( arguments.positionId );
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

		return arguments.position.getId();
	}

	private com.apirone.core.model.bean.QuotationItemPosition function build( required String positionId ){
		var record = getDao().read( arguments.positionId );
		if ( record.recordCount ) {
			return buildFromFindRow( record );
		}
		return NullValue();
	}

	/**
	 * Costruisce un bean QuotationItemPosition a partire da una riga della query.
	 */
	private com.apirone.core.model.bean.QuotationItemPosition function buildFromFindRow( required any record ){
		var bean = super.bean( "QuotationItemPosition" );

		// Campi diretti dal record (QuotationItemPosition non ha sub-entity)
		bean.setId( record.quotation_item_position_id );
		bean.setQuotationItemId( record.quotation_item_id );
		bean.setCoordinateX( record.coordinate_x );
		bean.setCoordinateY( record.coordinate_y );
		bean.setVisible( record.visible );
		bean.setAngle( record.angle );

		return bean;
	}

}
