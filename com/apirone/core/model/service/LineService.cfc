component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="LineDAO";
	property name="statusService" inject="StatusService";
	property name="lookupService" inject="LookupService";
	property name="productCategoryService" inject="ProductCategoryService";
	property name="productItemService" inject="ProductItemService";
	property name="productService" inject="ProductService";
	property name="componentService" inject="ComponentService";
	property name="componentOverrideService" inject="ComponentOverrideService";
	property name="textService" inject="TextService";
	// property name="wirebox" inject="Wirebox";
	// property name="mementifier" inject="ResultsMapper@mementifier";

	property name="cacheScope" type="String" default="Line.bean";

	public com.apirone.core.model.bean.Line function get( required String lineId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.lineId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.lineId );
		cm.put( getCacheScope(), arguments.lineId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		String categoryId,
		String statusId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "line.code", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( lineId = record.line_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/**
	 * @auditEvent line.created
	 * @auditMessage Line [@return@] created
	 * @auditPayload { "id": "@return@" }
	 */
	public String function create( required com.apirone.core.model.bean.Line line ){
		transaction {
			var newId = getDao().insert( arguments.line );

			for ( var text in arguments.line.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "line.id" );
				entity.setValue( newId );

				text.setEntity( entity );
			}

			getTextService().bulkCreate( arguments.line.getTexts() );
		}

		return newId;
	}

	/**
	 * @auditEvent line.cloned
	 * @auditMessage Line [@fromLineId@] cloned to [@toLineId@]
	 * @auditPayload { "fromLineId": "@fromLineId@", "toLineId": "@toLineId@", "categoryId": "@categoryId@" }
	 */
	public Struct function clone(
		required String fromLineId,
		required String toLineId,
		required Numeric categoryId
	){
		// recursive function to create product items

		var productService   = getProductService();
		var componentService = getComponentService();

		function createProductItem(
			required String productId,
			required Struct productItem,
			required Numeric level = 1
		){
			arguments.productItem.setProductId( arguments.productId );

			var newProductItemId = getProductItemService().create( arguments.productItem );

			// **
			// duplicate components of productItem
			// **

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

					getComponentOverrideService().create( overrideBean );
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

		productService.deleteAllByParams( lineId = toLineId, categoryId = categoryId );

		var products = productService.list( lineId = fromLineId, categoryId = categoryId );

		for ( var product in products ) {
			var newProduct = Duplicate( product );
			newProduct.getLine().setId( arguments.toLineId );

			var newId = productService.create( newProduct );

			// duplicate components of product
			var productComponents = getComponentService().list( productId = product.getId() );

			for ( var itemProductComponent in productComponents ) {
				var newProductComponent = Duplicate( itemProductComponent );

				newProductComponent.setId( "" );
				newProductComponent.getProduct().setId( newId );

				getComponentService().create( newProductComponent );
			}

			// duplicate productItems
			var productItems = getProductItemService().getTree( productId = product.getId() );

			for ( var productItem in productItems ) {
				createProductItem(
					productItem = productItem,
					level       = 1,
					productId   = newId
				);
			}
		}

		getCacheManager().removeAll();

		// super.logAction( type = "LINE.CLONED", message = "Line [#arguments.fromLineId#] cloned" )

		return {
			"status"  = "success",
			"payload" = {
				"fromLineId" = arguments.fromLineId,
				"toLineId"   = arguments.toLineId,
				"categoryId" = arguments.categoryId
			}
		};
	}

	/**
	 * @auditEvent line.updated
	 * @auditMessage Line [@line.id@] updated
	 * @auditPayload { "id": "@line.id@" }
	 */
	public String function update( required com.apirone.core.model.bean.Line line ){
		getDao().update( arguments.line );

		var id = arguments.line.getId();

		for ( var text in arguments.line.getTexts() ) {
			var entity = super.bean( "Entity" )

			entity.setKey( "line.id" );
			entity.setValue( id );

			text.setEntity( entity );

			if ( Len( text.getId() ) ) {
				getTextService().update( text );
			} else {
				getTextService().create( text );
			}
		}

		super.getCacheManager().remove( getCacheScope(), arguments.line.getId() );

		return arguments.line.getId();
	}

	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.line_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}

	/**
	 * @auditEvent line.deleted
	 * @auditMessage Line [@lineId@] deleted
	 * @auditPayload { "id": "@lineId@" }
	 */
	public com.apirone.core.model.bean.Outcome function delete( required String lineId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.lineId );

		outcome.setData( { lineId = arguments.lineId } );

		transaction {
			try {
				var result = getDao().delete( arguments.lineId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( getCacheScope(), arguments.lineId );

				// super.logAction( type = "LINE.DELETED", message = "Line [#arguments.lineId#] deleted" );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteLine" );
				outcome.setMessage( "Cannot delete line [#arguments.lineId#]" );
			}
		}

		return outcome;
	}

	public com.apirone.core.model.bean.Outcome function deleteByParams(
		required String lineId,
		required String categoryId
	){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.lineId );

		outcome.setData( { lineId = arguments.lineId } );

		transaction {
			try {
				var result = getDao().delete( lineId = arguments.lineId, categoryId = arguments.categoryId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( getCacheScope(), arguments.lineId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteLine" );
				outcome.setMessage( "Cannot delete line [#arguments.lineId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.Line function build( required String lineId ){
		var record = getDao().read( arguments.lineId );

		if ( record.recordCount ) {
			var bean = super.bean( "Line" );

			bean.setThickness( getLookupService().get( "thickness", record.thickness_id ) );

			bean.setTexts( getTextService().list( lineId = record.line_id ) );

			bean.setName( bean.getName() );

			bean.setId( record.line_id );
			bean.setCode( record.code );
			bean.setCreatedAt( record.created_at );

			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setCategories( super.getCategoriesBeanByIds( record.categories ) );

			return bean;
		}

		return NullValue();
	}

}
