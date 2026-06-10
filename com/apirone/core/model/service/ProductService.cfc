component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ProductDAO";
	property name="ModelService" inject="ModelService";
	property name="LineService" inject="LineService";
	property name="FinishService" inject="FinishService";
	property name="StatusService" inject="StatusService";
	property name="ProductCategoryService" inject="ProductCategoryService";
	property name="CatalogBundleService" inject="CatalogBundleService";
	property name="PriceService" inject="PriceService";
	property name="TextService" inject="TextService";
	property name="FileService" inject="FileService";
	property name="ProductItemService" inject="ProductItemService";
	property name="componentService" inject="ComponentService";
	property name="componentOverrideService" inject="ComponentOverrideService";

	public com.apirone.core.model.bean.Product function get( required String productId ){
		return build( arguments.productId );
	}

	public com.apirone.core.model.bean.Product function getByParams(
		required String lineId,
		required String finishId,
		required String modelId
	){
		var record = getDao().find( argumentCollection = arguments );

		if ( record.recordcount == 1 ) {
			return get( record.product_id );
		}

		return NullValue();
	}

	public function readIds(){
		return getDao().readIds();
	}

	public Array function list(){
		// TODO: check formatter
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.product_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		String lineId,
		String catalogBundleId,
		Array excludedCategoryIds = [],
		required Numeric limit    = 15,
		required Numeric offset   = 0,
		required Array orderBy    = [ { field = "product.id" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( r ){
			ids.append( r.product_id );
		} );

		var beanMap = {};
		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );

			allRecords.each( function( r ){
				beanMap[ r.product_id ] = buildFromRow( r );
			} );
		}

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.product_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String productId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.productId );

		outcome.setData( { productId = arguments.productId } );

		transaction {
			try {
				getDao().delete( arguments.productId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteProduct" );
				outcome.setMessage( "Cannot delete product [#arguments.productId#]" );
			}
		}

		return outcome;
	}

	public com.apirone.core.model.bean.Outcome function deleteByParams(
		required String lineId,
		required String finishId,
		required String modelId
	){
		var outcome = super.bean( "Outcome" );

		var obj = getByParams( argumentCollection = arguments );

		var productId = obj.getId()

		outcome.setData( { productId = productId } );

		transaction {
			try {
				getDao().delete( obj.getId() );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.error.CannotDeleteProduct" );
				outcome.setMessage( "Cannot delete product [#productId#]" );
			}
		}


		return outcome;
	}

	public com.apirone.core.model.bean.Outcome function deleteAllByParams(
		required String lineId,
		required String categoryId
	){
		var outcome = super.bean( "Outcome" );

		outcome.setData( arguments );

		transaction {
			getDao().deleteAllByParams( lineId = arguments.lineId, categoryId = arguments.categoryId );
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.Product product ){
		var product = this.handleCatalogBundle( arguments.product );

		var newId = getDao().insert( product );

		if ( !IsNull( product.getTexts() ) AND product.getTexts().len() ) {
			transaction {
				for ( var text in product.getTexts() ) {
					var entity = super.bean( "Entity" );
					entity.setKey( "product.id" );
					entity.setValue( newId );
					text.setEntity( entity );
				}
				getTextService().bulkCreate( product.getTexts() );
			}
		}

		return newId;
	}

	public Struct function cloneTree( required String fromProductId, required String toProductId ){
		if ( fromProductId == toProductId ) {
			Throw(
				type    = "ApirOne.errors.productService.InvalidArgument",
				message = "fromProductId and toProductId cannot be the same"
			);
		}

		super.logEvent(
			event   = "product.CLONED_TREE",
			message = "Start clone tree of product [#arguments.fromProductId#] to [#arguments.toProductId#]",
			payload = {
				"fromProductId" = arguments.fromProductId,
				"toProductId"   = arguments.toProductId
			}
		);

		var componentService         = getComponentService();
		var componentOverrideService = getComponentOverrideService();

		function createProductItem(
			required String productId,
			required com.apirone.core.model.bean.ProductItem productItem,
			required Numeric level = 1
		){
			arguments.productItem.setProductId( arguments.productId );

			var newProductItemId = getProductItemService().create( arguments.productItem );

			var components = componentService.list(
				productItemId                  = arguments.productItem.getId(),
				includeBaseAttributeComponents = true
			);

			// TODO: move this logic tu ComponentService
			// We have in ComponentAjaxController too
			for ( var thisComponent in components ) {
				getLogger().debug( "Override [#thisComponent.getId()#] typeId [#thisComponent.getTypeId()#]" );

				// **
				// override components
				// **

				if ( thisComponent.getTypeId() == "base" ) {
					var overrideBean = super.bean( "ComponentOverride" );

					overrideBean.setId( "" );
					overrideBean.setDeleted( thisComponent.getOverride().getDeleted() );
					overrideBean.setQuantity( thisComponent.getOverride().getQuantity() );
					overrideBean.setComponentId( thisComponent.getId() );
					overrideBean.setProductItemId( newProductItemId );

					componentOverrideService.create( overrideBean );
				} else {
					var newComponent = Duplicate( thisComponent );

					newComponent.setId( "" );
					newComponent.getProductItem().setId( newProductItemId );

					componentService.create( newComponent );
				}
			}

			if ( arguments.productItem.getChildren().len() ) {
				for ( var child in arguments.productItem.getChildren() ) {
					child.getOrigin().setId( newProductItemId );

					createProductItem(
						productItem = child,
						level       = arguments.level + 1,
						productId   = arguments.productId
					);
				}
			}
		}

		transaction {
			getProductItemService().delete( productId = arguments.toProductId );

			var productItems = getProductItemService().getTree( productId = arguments.fromProductId );

			for ( var productItem in productItems ) {
				createProductItem(
					productItem = productItem,
					level       = 1,
					productId   = arguments.toProductId
				);
			}
		}

		super.logEvent(
			event   = "product.CLONED_TREE",
			message = "End clone tree of product [#arguments.fromProductId#] to [#arguments.toProductId#]",
			payload = {
				"fromProductId" = arguments.fromProductId,
				"toProductId"   = arguments.toProductId
			}
		);

		return {
			"status"  = "success",
			"payload" = {
				"fromProductId" = arguments.fromProductId,
				"toProductId"   = arguments.toProductId
			}
		};
	}

	public String function updateDetail( required com.apirone.core.model.bean.Product product ){

		getDao().updateDetail( arguments.product );

		return product.getId();
	}

	public String function update( required com.apirone.core.model.bean.Product product ){
		var product = this.handleCatalogBundle( arguments.product );

		getDao().update( arguments.product );

		var id = product.getId();

		if ( !IsNull( arguments.product.getTexts() ) ) {
			for ( var text in arguments.product.getTexts() ) {
				var entity = super.bean( "Entity" )

				entity.setKey( "product.id" );
				entity.setValue( id );

				text.setEntity( entity );

				if ( Len( text.getId() ) ) {
					getTextService().update( text );
				} else {
					getTextService().create( text );
				}
			}
		}

		return product.getId();
	}


	/*
			private method
	*/

	// normalize data for catalogBundle
	private com.apirone.core.model.bean.Product function handleCatalogBundle(
		required com.apirone.core.model.bean.Product product
	){
		if ( IsInstanceOf( product, "com.apirone.core.model.bean.ProductComplex" ) ) {
			var bundle = super.bean( "CatalogBundle" );
			bundle.setLine( product.getLine() );
			bundle.setModel( product.getModel() );
			bundle.setCategory( product.getCategory() );

			var catalogBundle = getCatalogBundleService().getOrCreate( bundle );
			product.setCatalogBundle( catalogBundle );
		}

		return product;
	}

	/**
	 * Costruisce un bean Product a partire dall'ID. Delega a buildFromRow() dopo la lettura del record.
	 */
	private com.apirone.core.model.bean.Product function build( required String productId ){
		var record = getDao().read( arguments.productId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Product a partire da una riga del query.
	 * Le sub-entity (Category, Status, Texts, Prices, Files, ecc.) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.Product function buildFromRow( required any record ){
		// Campi diretti dal record (distingue ProductBase da ProductComplex)
		if ( IsNull( arguments.record.catalog_bundle_id ) ) {
			var bean = super.bean( "ProductBase" );

			bean.setCode( arguments.record.code );
			bean.setCategory( getProductCategoryService().get( arguments.record.product_category_id ) );
			bean.setPositionCount( arguments.record.position_count );
			bean.setLines( super.getLinesBeanByIds( arguments.record.lines ) );
		} else {
			var bean = super.bean( "ProductComplex" );

			bean.setCatalogBundle( getCatalogBundleService().get( arguments.record.catalog_bundle_id ) );

			bean.setLine( bean.getCatalogBundle().getLine() );
			bean.setModel( bean.getCatalogBundle().getModel() );
			bean.setCategory( bean.getCatalogBundle().getCategory() );
			bean.setFinish( getFinishService().get( arguments.record.finish_id ) );
		}

		// Campi comuni
		bean.setId( arguments.record.product_id.toString() );
		bean.setSerial( arguments.record.serial );
		bean.setCreatedAt( arguments.record.created_at );
		bean.setSpecial( BooleanFormat( arguments.record.special ) ); //TODO: to remove
		bean.setMinQuantity( arguments.record.min_quantity );
		bean.setMaxQuantity( arguments.record.max_quantity );
		bean.setMarginTop( arguments.record.margin_top );
		bean.setMarginLeft( arguments.record.margin_left );
		bean.setPlateWidth( arguments.record.plate_width );
		bean.setPlateHeight( arguments.record.plate_height );

		// Entity collegate (caricate singolarmente)
		bean.setStatus( getStatusService().get( arguments.record.status_id ) );
		bean.setTexts( getTextService().list( productId = arguments.record.product_id ) );
		bean.setImportantAttributes( super.getAttributesBeanByIds( arguments.record.attributes_important ) );
		bean.setPrices( getPriceService().list( productId = arguments.record.product_id ) );

		var images = getFileService().list( productId = arguments.record.product_id );
		if ( Len( images ) ) {
			bean.setImages( images )
		}

		return bean;
	}

}
