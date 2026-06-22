component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao"                      inject="QuotationItemDraftDAO";
	property name="cacheScope"               type="String" default="QuotationItemDraft.bean";

	public com.apirone.core.model.bean.QuotationItemDraft function get( required String draftId ){
		var cm    = getCacheManager();
		var cache = cm.get( getCacheScope(), arguments.draftId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.draftId );
		cm.put( getCacheScope(), arguments.draftId, bean );

		return bean;
	}

	public Array function listByZone( required String quotationZoneId ){
		var rows    = [];
		var records = getDao().findByZone( arguments.quotationZoneId );

		records.each( function( record ){
			rows.add( get( draftId = record.quotation_item_draft_id ) );
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
		getCacheManager().remove( getCacheScope(), arguments.draftId );
	}

	public void function delete( required String draftId ){
		getDao().delete( arguments.draftId );
		getCacheManager().remove( getCacheScope(), arguments.draftId );
	}

	private com.apirone.core.model.bean.QuotationItemDraft function build( required String draftId ){
		var record = getDao().read( arguments.draftId );
		if ( record.recordCount ) {
			var bean = super.bean( "QuotationItemDraft" );
			bean.setId( record.quotation_item_draft_id );
			bean.setQuotationId( record.quotation_id );
			bean.setQuotationZoneId( record.quotation_zone_id );
			bean.setItemType( record.item_type );
			if ( !IsNull( record.coordinate_x ) ) bean.setCoordinateX( record.coordinate_x );
			if ( !IsNull( record.coordinate_y ) ) bean.setCoordinateY( record.coordinate_y );
			if ( !IsNull( record.angle ) )         bean.setAngle( record.angle );
			if (  Len( record.created_at ) )       bean.setCreatedAt( record.created_at );
			return bean;
		}
		return NullValue();
	}

}
