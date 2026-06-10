component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ProductCategoryTypeDAO";
	property name="statusService" inject="StatusService";

	public com.apirone.core.model.bean.ProductCategoryType function get( required String productCategoryTypeId ){
		return build( arguments.productCategoryTypeId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	private com.apirone.core.model.bean.Result function search(
		String str,
		String statusId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "productCategoryType.orderby" } ]
	){
		var result = super.getResult();
		var rows   = [];

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie gli ID restituiti dalla find per un caricamento batch
		var ids = [];
		for ( var record in records ) {
			ids.add( record.product_category_type_id );
		}

		// Carica tutti i record completi in un'unica query e costruisce una mappa id -> bean
		if ( ids.len() ) {
			var fullRecords = getDao().readByIds( ids );
			var beanMap = {};

			for ( var fullRecord in fullRecords ) {
				beanMap[ fullRecord.product_category_type_id ] = buildFromRow( fullRecord );
			}

			// Itera i record originali per preservare l'ordinamento della find
			for ( var record in records ) {
				rows.add( beanMap[ record.product_category_type_id ] );
			}
		}

		result.setTotal( records.total );
		result.setCount( records.recordCount() );
		result.setData( rows );

		return result;
	}

	/**
	 * Costruisce un bean ProductCategoryType a partire da una riga della query.
	 */
	private com.apirone.core.model.bean.ProductCategoryType function buildFromRow( required any record ){
		var bean = super.bean( "ProductCategoryType" );

		bean.setId( record.product_category_type_id );
		// Entity collegata (Status è un lookup leggero)
		bean.setStatus( getStatusService().get( record.status_id ) );
		bean.setCreatedAt( record.created_at );
		bean.setName( record.product_category_type );

		return bean;
	}

	private com.apirone.core.model.bean.ProductCategoryType function build( required String productCategoryTypeId ){
		var record = getDao().read( arguments.productCategoryTypeId );

		if ( record.RecordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

}
