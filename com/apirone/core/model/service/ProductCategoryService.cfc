component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ProductCategoryDAO";
	property name="statusService" inject="StatusService";
	property name="textService" inject="TextService";
	property name="lookupService" inject="LookupService";
	property name="productCategoryTypeService" inject="ProductCategoryTypeService";

	public com.apirone.core.model.bean.ProductCategory function get( required String productCategoryId ){
		return build( arguments.productCategoryId );
	}

	public Array function list(
		String str,
		String rawProductId,
		required Array orderBy = [ { field = "ProductCategory.code" } ]
	){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		String lineId,
		String modeId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "productCategory.id" } ]
	){
		var rows = [];

		var result = super.getResult()

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( record ){
			ids.append( record.product_category_id );
		} );

		var beanMap = {};
		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );
			allRecords.each( function( record ){
				beanMap[ record.product_category_id ] = buildFromRow( record );
			} );
		}

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.product_category_id ] );
		} );

		result.setTotal( Val( records.total ) );
		result.setCount( Val( records.recordCount ) );
		result.setData( rows );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.ProductCategory ProductCategory ){
		if ( !Len( arguments.ProductCategory.getCode() ) ) {
			Throw( type = "apirone.error.codeNotProvided", message = "Code required" );
		};

		if ( !Len( arguments.ProductCategory.getTexts() ) ) {
			Throw( type = "apirone.error.noTexsProvided", message = "At least one description required" );
		};

		transaction {
			var newId = getDao().insert( arguments.ProductCategory );

			for ( var text in arguments.ProductCategory.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "ProductCategory.id" );
				entity.setValue( newId );

				text.setEntity( entity );
			}

			getTextService().bulkCreate( arguments.ProductCategory.getTexts() );
		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.ProductCategory ProductCategory ){
		if ( !Len( arguments.ProductCategory.getCode() ) ) {
			Throw( type = "apirone.error.codeNotProvided", message = "Code required" );
		};

		if ( !Len( arguments.ProductCategory.getTexts() ) ) {
			Throw( type = "apirone.error.noTexsProvided", message = "At least one description required" );
		};

		var id = getDao().update( arguments.ProductCategory );

		for ( var text in arguments.ProductCategory.getTexts() ) {
			var entity = super.bean( "Entity" );

			entity.setKey( "ProductCategory.id" );
			entity.setValue( id );

			text.setEntity( entity );

			getTextService().update( text );
		}

		return id;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String productCategoryId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.productCategoryId );

		outcome.setData( { productCategoryId = arguments.productCategoryId } );

		transaction {
			try {
				var result = getDao().delete( arguments.productCategoryId );
				outcome.setData( { "deletedCount" = result } )
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteProductCategory" );
				outcome.setMessage( "Cannot delete product category [#arguments.productCategoryId#]" );
			}
		}

		return outcome;
	}

	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.product_category_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}


	/*
    	private methods
	*/

	private com.apirone.core.model.bean.ProductCategory function build( required String ProductCategoryId ){
		var record = getDao().read( arguments.ProductCategoryId );

		if ( record.RecordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean ProductCategory a partire da una riga della query, senza chiamata DB aggiuntiva
	 * per il record principale.
	 */
	public com.apirone.core.model.bean.ProductCategory function buildFromRow( required any record ){
		var bean = super.bean( "ProductCategory" );

		// Campi diretti dal record
		bean.setId( record.product_category_id );
		bean.setCode( record.code );
		bean.setCreatedAt( record.created_at );

		// Entity collegate (caricate singolarmente)
		bean.setStatus( getStatusService().get( record.status_id ) );
		bean.setType(
			getProductCategoryTypeService().get( productCategoryTypeId = record.product_category_type_id )
		);
		bean.setMode( getLookupService().get( "ProductCategoryMode", record.mode_id ) );

		// Testi (caricati singolarmente per categoria)
		var texts = getTextService().list( productCategoryId = record.product_category_id );
		bean.setTexts( texts );
		bean.setName( bean.getName() );

		return bean;
	}

	/**
	 * Recupera in batch più ProductCategory dato un array di ID.
	 * Restituisce uno Struct chiave = categoryId, valore = bean ProductCategory.
	 * Sostituisce il pattern di AbsService.getCategoriesBeanByIds() che chiama get() per ogni ID.
	 *
	 * Effettua pre-caricamento locale di status, type e mode per evitare chiamate duplicate
	 * al DB quando più categorie condividono gli stessi valori.
	 *
	 * @ids Array di productCategoryId
	 * @return Struct mappato per productCategoryId -> ProductCategory
	 */
	public Struct function getMany( required Array ids ){
		// Carica tutti i record in una sola query
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Cache locali per status, type e mode: evita chiamate duplicate al DB
		var statuses    = {};
		var types       = {};
		var modes       = {};

		for ( var record in records ) {
			var bean = super.bean( "ProductCategory" );

			// Testi: chiamata individuale per categoria
			var texts = getTextService().list( productCategoryId = record.product_category_id );
			bean.setTexts( texts );
			bean.setName( bean.getName() );

			// Campi diretti dal record
			bean.setId( record.product_category_id );
			bean.setCode( record.code );

			// Status: cached localmente
			if ( !StructKeyExists( statuses, record.status_id ) ) {
				statuses[ record.status_id ] = getStatusService().get( record.status_id );
			}
			bean.setStatus( statuses[ record.status_id ] );

			bean.setCreatedAt( record.created_at );

			// Type: cached localmente
			if ( !StructKeyExists( types, record.product_category_type_id ) ) {
				types[ record.product_category_type_id ] = getProductCategoryTypeService().get( productCategoryTypeId = record.product_category_type_id );
			}
			bean.setType( types[ record.product_category_type_id ] );

			// Mode: cached localmente
			if ( !StructKeyExists( modes, record.mode_id ) ) {
				modes[ record.mode_id ] = getLookupService().get( "ProductCategoryMode", record.mode_id );
			}
			bean.setMode( modes[ record.mode_id ] );

			map[ record.product_category_id ] = bean;
		}

		return map;
	}

}
