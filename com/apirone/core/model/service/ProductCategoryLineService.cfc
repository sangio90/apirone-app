component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ProductCategoryLineDAO";
	property name="lineService" inject="lineService";
	property name="productCategoryService" inject="productCategoryService";

	public com.apirone.core.model.bean.ProductCategoryLine function get( required String ProductCategoryLineId ){
		return build( arguments.ProductCategoryLineId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	/**
	 * Recupera in batch tutte le ProductCategoryLine per una categoria.
	 * Evita l'N+1 di list() chiamato in un loop per ogni lineId.
	 *
	 * @categoryId ID della categoria prodotto
	 * @return Array di bean ProductCategoryLine
	 */
	public Array function listByCategoryId( required Numeric categoryId ){
		var records = getDao().findByCategoryId( arguments.categoryId );
		var rows    = [];

		for ( var record in records ) {
			rows.add( buildFromRow( record ) );
		}

		return rows;
	}


	public com.apirone.core.model.bean.Result function search(
		String categoryId,
		String lineId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "productCategoryLine.id", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie gli ID restituiti dalla find per un caricamento batch
		var ids = [];
		for ( var record in records ) {
			ids.add( record.product_category_line_id );
		}

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Itera i record originali per preservare l'ordinamento della find
		for ( var record in records ) {
			rows.add( beanMap[ record.product_category_line_id ] );
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public Numeric function create( required com.apirone.core.model.bean.ProductCategoryLine productCategoryLine ){
		transaction {
			getDao().deleteByParams(
				lineId            = productCategoryLine.getLine().getId(),
				productCategoryId = productCategoryLine.getProductCategory().getId()
			);
			var newId = getDao().insert( arguments.productCategoryLine );
		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.ProductCategoryLine productCategoryLine ){
		getDao().update( arguments.productCategoryLine );

		return arguments.productCategoryLine.getId();
	}

	public com.apirone.core.model.bean.Outcome function delete( required String productCategoryLineId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { productCategoryLineId = arguments.productCategoryLineId } );

		transaction {
			try {
				var result = getDao().delete( arguments.productCategoryLineId );
				outcome.setData( { "deletedCount" = result } )
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.error.CannotDeleteProductCategoryLine" );
				outcome.setMessage( "Cannot delete productCategoryLine id [#arguments.productCategoryLineId#]" );
			}
		}

		return outcome;
	}


	/**
	 * Recupera in batch più ProductCategoryLine dato un array di ID.
	 * Restituisce uno Struct chiave = productCategoryLineId, valore = bean ProductCategoryLine.
	 * Precarica linee e categorie in batch per evitare il problema N+1.
	 *
	 * @ids Array di productCategoryLineId
	 * @return Struct mappato per productCategoryLineId -> ProductCategoryLine
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie gli ID unici di linee e categorie da tutti i record
		var lineIds     = [];
		var categoryIds = [];
		for ( var record in records ) {
			if ( !IsNull( record.line_id ) ) {
				lineIds.append( record.line_id );
			}
			if ( !IsNull( record.product_category_id ) ) {
				categoryIds.append( record.product_category_id );
			}
		}

		// Precarica le linee in batch tramite LineService.getMany()
		var lineMap = {};
		if ( ArrayLen( lineIds ) ) {
			lineMap = getLineService().getMany( lineIds );
		}

		// Precarica le categorie in batch tramite ProductCategoryService.getMany()
		var categoryMap = {};
		if ( ArrayLen( categoryIds ) ) {
			categoryMap = getProductCategoryService().getMany( categoryIds );
		}

		for ( var record in records ) {
			var bean = super.bean( "ProductCategoryLine" );

			bean.setId( record.product_category_line_id );
			bean.setCreatedAt( record.created_at );
			bean.setMarkup( record.markup );

			// Line: dalla mappa pre-caricata
			if ( StructKeyExists( lineMap, record.line_id ) ) {
				bean.setLine( lineMap[ record.line_id ] );
			}

			// ProductCategory: dalla mappa pre-caricata
			if ( StructKeyExists( categoryMap, record.product_category_id ) ) {
				bean.setProductCategory( categoryMap[ record.product_category_id ] );
			}

			map[ record.product_category_line_id ] = bean;
		}

		return map;
	}

	/**
	 * Costruisce un bean ProductCategoryLine a partire da una riga della query.
	 */
	private com.apirone.core.model.bean.ProductCategoryLine function buildFromRow( required any record ){
		var bean = super.bean( "ProductCategoryLine" );

		bean.setId( record.product_category_line_id );
		bean.setCreatedAt( record.created_at );
		bean.setMarkup( record.markup );
		// Entity collegate (Line e ProductCategory sono lookup leggeri)
		bean.setLine( getLineService().get( record.line_id ) );
		bean.setProductCategory( getProductCategoryService().get( record.product_category_id ) );

		return bean;
	}

	private com.apirone.core.model.bean.ProductCategoryLine function build( required String productCategoryLineId ){
		var record = getDao().read( arguments.productCategoryLineId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

}
