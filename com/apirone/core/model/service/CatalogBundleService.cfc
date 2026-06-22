component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="CatalogBundleDAO";
	property name="lineService" inject="LineService";
	property name="modelService" inject="ModelService";
	property name="productCategoryService" inject="ProductCategoryService";

	public com.apirone.core.model.bean.CatalogBundle function get( required String catalogBundleId ){
		return build( arguments.catalogBundleId );
	}

	public Array function list(){
		var rows = [];

		return search( argumentCollection = arguments ).getData();
	}

	public String function findId(
		required String modelId,
		required Numeric categoryId,
		required String lineId
	){
		var record = getDao().find( argumentCollection = arguments );

		return Len( record.catalog_bundle_id ) ? record.catalog_bundle_id : NullValue();
	}

	public String function update( required com.apirone.core.model.bean.CatalogBundle catalogBundle ){
		getDao().update( arguments.catalogBundle );

		super.logEvent(
			event   = "CATALOG_BUNDLE.updated",
			message = "CatalogBundle [#arguments.catalogBundle.getId()#] updated"
		);

		return arguments.catalogBundle.getId();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		String categoryId,
		String modelId,
		String lineId,
		String statusId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "catalogBundle.createdAt", dir = "desc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( r ){
			ids.append( r.catalog_bundle_id );
		} );

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.catalog_bundle_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/**
	 * Recupera in batch più CatalogBundle dato un array di ID.
	 * Restituisce uno Struct chiave = catalogBundleId, valore = bean CatalogBundle.
	 * Precarica Line, Model e Category in batch per evitare il problema N+1.
	 *
	 * @ids Array di catalogBundleId
	 * @return Struct mappato per catalogBundleId -> CatalogBundle
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie tutti gli ID delle FK da precaricare in batch
		var lineIds     = [];
		var modelIds    = [];
		var categoryIds = [];

		for ( var record in records ) {
			if ( !IsNull( record.line_id ) ) {
				lineIds.append( record.line_id );
			}
			if ( !IsNull( record.model_id ) ) {
				modelIds.append( record.model_id );
			}
			if ( !IsNull( record.product_category_id ) ) {
				categoryIds.append( record.product_category_id );
			}
		}

		// Precarica le entity FK con getMany() esistenti (1 query ciascuna)
		var lineMap = {};
		if ( ArrayLen( lineIds ) ) {
			lineMap = getLineService().getMany( lineIds );
		}

		var modelMap = {};
		if ( ArrayLen( modelIds ) ) {
			modelMap = getModelService().getMany( modelIds );
		}

		var categoryMap = {};
		if ( ArrayLen( categoryIds ) ) {
			categoryMap = getProductCategoryService().getMany( categoryIds );
		}

		// Costruisce i bean con le mappe pre-caricate
		for ( var record in records ) {
			var bean = super.bean( "CatalogBundle" );

			// Campi diretti dal record
			bean.setId( record.catalog_bundle_id );
			bean.setName( record.catalog_bundle );
			bean.setCreatedAt( record.created_at );
			bean.setMarkupValue( record.markup_value );

			// Entity collegate dalle mappe pre-caricate
			if ( StructKeyExists( lineMap, record.line_id ) ) {
				bean.setLine( lineMap[ record.line_id ] );
			}

			if ( StructKeyExists( modelMap, record.model_id ) ) {
				bean.setModel( modelMap[ record.model_id ] );
			}

			if ( StructKeyExists( categoryMap, record.product_category_id ) ) {
				bean.setCategory( categoryMap[ record.product_category_id ] );
			}

			map[ record.catalog_bundle_id ] = bean;
		}

		return map;
	}

	public com.apirone.core.model.bean.CatalogBundle function getOrCreate(
		required com.apirone.core.model.bean.CatalogBundle catalogBundle
	){
		var record = getDao().find(
			lineId     = arguments.catalogBundle.getLine().getId(),
			modelId    = arguments.catalogBundle.getModel().getId(),
			categoryId = arguments.catalogBundle.getCategory().getId()
		);

		if ( !record.recordCount ) {
			var bean = super.bean( "CatalogBundle" );

			var newId = create( arguments.catalogBundle );

			return get( newId );
		}

		return get( record.catalog_bundle_id );
	}

	public String function create( required com.apirone.core.model.bean.CatalogBundle catalogBundle ){
		var newId = getDao().insert( arguments.catalogBundle );

		return newId;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.CatalogBundle function build( required String catalogBundleId ){
		var record = getDao().read( arguments.catalogBundleId );

		if ( record.RecordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean CatalogBundle a partire da una riga della query.
	 * Le sub-entity (Line, Model, Category) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.CatalogBundle function buildFromRow( required any record ){
		var bean = super.bean( "CatalogBundle" );

		// Campi diretti dal record
		bean.setId( arguments.record.catalog_bundle_id );
		bean.setName( arguments.record.catalog_bundle );
		bean.setCreatedAt( arguments.record.created_at );
		bean.setMarkupValue( arguments.record.markup_value );

		// Entity collegate (caricate singolarmente)
		bean.setLine( getLineService().get( arguments.record.line_id ) );
		bean.setModel( getModelService().get( arguments.record.model_id ) );
		bean.setCategory( getProductCategoryService().get( arguments.record.product_category_id ) );

		return bean;
	}

}
