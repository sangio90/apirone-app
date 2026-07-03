component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemDraftDAO";

	public com.apirone.core.model.bean.QuotationItemDraft function get( required String draftId ){
		return build( arguments.draftId );
	}

	public Array function listByZone( required String quotationZoneId ){
		var rows    = [];
		var records = getDao().findByZone( arguments.quotationZoneId );

		records.each( function( record ){
			rows.add( buildFromRow( record ) );
		} );

		return rows;
	}

	public Numeric function countByQuotation( required String quotationId ){
		return getDao().countByQuotation( arguments.quotationId );
	}

	public String function create( required com.apirone.core.model.bean.QuotationItemDraft draft ){
		var newId = getDao().insert( arguments.draft );
		return newId;
	}

	public void function updatePosition(
		required String  draftId,
		required Numeric coordinateX,
		required Numeric coordinateY,
		required Numeric angle
	){
		var draft = get( arguments.draftId );
		draft.setCoordinateX( arguments.coordinateX );
		draft.setCoordinateY( arguments.coordinateY );
		draft.setAngle( Int( arguments.angle ) );
		getDao().update( draft );
	}

	public void function delete( required String draftId ){
		getDao().delete( arguments.draftId );
	}

	private com.apirone.core.model.bean.QuotationItemDraft function build( required String draftId ){
		var record = getDao().read( arguments.draftId );
		if ( record.recordCount ) {
			return buildFromRow( record );
		}
		return NullValue();
	}

	/**
	 * Costruisce un bean QuotationItemDraft a partire da una riga del query.
	 */
	private com.apirone.core.model.bean.QuotationItemDraft function buildFromRow( required any record ){
		var bean = super.bean( "QuotationItemDraft" );
		bean.setId( arguments.record.quotation_item_draft_id );
		bean.setQuotationId( arguments.record.quotation_id );
		bean.setQuotationZoneId( arguments.record.quotation_zone_id );
		bean.setItemType( arguments.record.item_type );
		if ( !IsNull( arguments.record.coordinate_x ) ) bean.setCoordinateX( arguments.record.coordinate_x );
		if ( !IsNull( arguments.record.coordinate_y ) ) bean.setCoordinateY( arguments.record.coordinate_y );
		if ( !IsNull( arguments.record.angle ) )         bean.setAngle( arguments.record.angle );
		if (  Len( arguments.record.created_at ) )       bean.setCreatedAt( arguments.record.created_at );
		return bean;
	}

}
