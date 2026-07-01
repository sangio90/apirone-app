component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ComponentDAO";
	property name="statusService" inject="StatusService";
	property name="rawProductService" inject="RawProductService";
	property name="variantService" inject="VariantService";
	property name="colorService" inject="ColorService";
	property name="productService" inject="ProductService";
	property name="productItemService" inject="ProductItemService";
	property name="productItemDAO" inject="ProductItemDAO";
	property name="componentOverrideService" inject="ComponentOverrideService";
	property name="lineService" inject="LineService";
	property name="modelService" inject="ModelService";
	property name="costService" inject="CostService";
	property name="signageConfigItemService" inject="SignageConfigItemService";
	property name="CatalogBundleService" inject="CatalogBundleService";
	property name="TextService" inject="TextService";
	property name="PriceService" inject="PriceService";
	property name="FileService" inject="FileService";
	property name="FinishService" inject="FinishService";
	property name="ProductCategoryService" inject="ProductCategoryService";

	public com.apirone.core.model.bean.Component function get( required String componentId ){
		return build( arguments.componentId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	/**
	 * Recupera in batch i componenti collegati a una lista di product_item_id.
	 * Restituisce un array di bean Component (own components) senza i base-attribute.
	 * Utilizzato da QuotationService.getComponents() per evitare N+1.
	 *
	 * @productItemIds Array di productItemId
	 * @return Array di bean Component
	 */
	public Array function listByProductItemIds( required Array productItemIds ){
		var records = getDao().readByProductItemIds( arguments.productItemIds );
		var ids     = [];
		for ( var r in records ) {
			ArrayAppend( ids, r.component_id );
		}

		if ( !ArrayLen( ids ) ) {
			return [];
		}

		var beanMap = getMany( ids );
		var result  = [];
		for ( var id in ids ) {
			if ( StructKeyExists( beanMap, id ) ) {
				ArrayAppend( result, beanMap[ id ] );
			}
		}

		return result;
	}

	/**
	 * Recupera in batch i componenti di tipo SignageItemProduct per una lista di
	 * product_item_id (join) dato l'ID della config segnaletica.
	 * Restituisce un array di bean Component.
	 * Utilizzato da QuotationService.getComponents() per evitare N+1.
	 *
	 * @signageConfigItemId ID della config segnaletica
	 * @productItemIds Array di productItemId (join)
	 * @return Array di bean Component
	 */
	public Array function listBySignageItemProductJoinIds(
		required String signageConfigItemId,
		required Array productItemIds
	){
		var records = getDao().readBySignageItemProductJoinIds(
			signageConfigItemId = arguments.signageConfigItemId,
			productItemIds      = arguments.productItemIds
		);
		var ids = [];
		for ( var r in records ) {
			ArrayAppend( ids, r.component_id );
		}

		if ( !ArrayLen( ids ) ) {
			return [];
		}

		var beanMap = getMany( ids );
		var result  = [];
		for ( var id in ids ) {
			if ( StructKeyExists( beanMap, id ) ) {
				ArrayAppend( result, beanMap[ id ] );
			}
		}

		return result;
	}

	public Numeric function count(
		String lineId,
		String modelId,
		String productId,
		Numeric productItemId,
		Numeric attributeValueId
	){
		var result = getDao().find( argumentCollection = arguments );

		return Val( result.total );
	}

	public Array function priceCalculatorSearch(
		String lineId,
		String modelId,
		String productId,
		Numeric productItemId,
		Numeric attributeValueId,
		Boolean includeBaseAttributeComponents = false hint="Only for product productItemId",
		limit = -1
	){
		if ( !IsNull( arguments.productItemId ) AND arguments.includeBaseAttributeComponents ) {
			return searchByProductItemIdForPriceCalculator( arguments.productItemId );
		}

		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			var component = getDao().priceCalculatorRead( componentId = record.component_id, productItemId = !isNull(arguments.productItemId) ? arguments.productItemId : null )
			rows.add(component)
		} );

		return rows
	}

	public com.apirone.core.model.bean.Result function search(
		// TODO: add category
		String lineId,
		String modelId,
		String productId,
		Numeric productItemId,
		Numeric attributeValueId,
		Boolean includeBaseAttributeComponents = false hint="Only for product productItemId"
	){
		if ( !IsNull( arguments.productItemId ) AND arguments.includeBaseAttributeComponents ) {
			return searchByProductItemId( arguments.productItemId );
		}

		var rows   = [];
		var result = super.getResult();

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( r ){
			ids.append( r.component_id );
		} );

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.component_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );
		return result;
	}

	public Numeric function massiveReassign(
		String rawProductId,
		String variantId,
		String colorId,
		String paramCategory,
		String newParam,
		String oldParam
	){
		arguments[ "limit" ] = -1;

		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );
		var params  = {};

		if ( paramCategory == "rawProductId" ) {
			params = { "paramCategory" = paramCategory, "newParam" = newParam }
		}

		if ( paramCategory == "variantId" ) {
			params = { "paramCategory" = paramCategory, "newParam" = newParam }
		}

		if ( paramCategory == "colorId" ) {
			params = { "paramCategory" = paramCategory, "newParam" = newParam }
		}

		super.logEvent(
			event   = "component.MULTI_UPDATED",
			message = "Massive component reassign procedure started",
			payload = {
				"criteria" = paramCategory,
				"oldValue" = oldParam,
				"newValue" = newParam
			}
		);
		records.each( function( record ){
			var rowParams              = params;
			rowParams[ "componentId" ] = record.component_id;
			
			getDao().reassign( argumentCollection = rowParams );
			
			super.logEvent(
				event   = "component.UPDATED",
				message = "Component [#rowParams[ "componentId" ]#] updated.",
				payload = {
					"criteria" = rowParams[ "paramCategory" ],
					"id"       = rowParams[ "componentId" ],
					"oldValue" = oldParam,
					"newValue" = rowParams[ "newParam" ]
				}
			);
		
		} );

		super.logEvent(
			event   = "component.MULTI_UPDATED",
			message = "Massive component reassign procedure ended",
			payload = {
				"criteria"      = paramCategory,
				"oldValue"      = oldParam,
				"newValue"      = newParam,
				"recordUpdated" = Val( records.recordcount )
			}
		);

		return Val( records.recordcount );
	}

	public Numeric function massiveDelete(
		String rawProductId,
		String variantId,
		String colorId,
		String paramCategory,
		String oldParam
	){
		arguments[ "limit" ] = -1;

		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );
		var params  = {};

		super.logEvent(
			event   = "component.MULTI_DELETED",
			message = "Massive component delete procedure started",
			payload = { "criteria" = paramCategory, "value" = oldParam }
		);

		records.each( function( record ){
			delete( record.component_id );
		} );

		super.logEvent(
			event   = "component.MULTI_DELETED",
			message = "Massive component delete procedure ended",
			payload = {
				"criteria"      = paramCategory,
				"value"         = oldParam,
				"recordDeleted" = Val( records.recordcount )
			}
		);

		return Val( records.recordcount );
	}

	public com.apirone.core.model.bean.Outcome function delete( required String componentId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.componentId, false );

		outcome.setData( { componentId = arguments.componentId } );

		transaction {
			try {
				getDao().delete( arguments.componentId );
				super.logEvent(
					event   = "component.DELETED",
					message = "Component [#arguments.componentId#] deleted.",
					payload = { "id" = arguments.componentId }
				);
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteComponent" );
				outcome.setMessage( "Cannot delete component [#arguments.componentId#]" );
			}
		}

		return outcome;
	}

	public com.apirone.core.model.bean.Outcome function deleteByParams(
		required  com.apirone.core.model.bean.Component component
	){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.component.getId() );

		outcome.setData( { component = arguments.component } );

		transaction {
			try {
				getDao().deleteByParams( arguments.component );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteComponent" );
				outcome.setMessage( "Cannot delete component [#obj.getId()#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.Component component ){
		// TODO: to fix, add validation

		if ( Len( arguments.component.getId() ) ) {
			var id = getDao().update( arguments.component.getId() );
		} else {
			var id = getDao().insert( arguments.component );
		}

		return id;
	}


	public String function update( required com.apirone.core.model.bean.Component component ){
		getDao().update( arguments.component );

		return arguments.component.getId();
	}


	/*
    	private method
	*/

	// TODO: di fatto avrebbe più senso sia searchByAttributeValueId, ma per ora lo lascio così
	private com.apirone.core.model.bean.Result function searchByProductItemId( required String productItemId ){
		var data   = [];
		var result = getResult();

		// components of productItem
		var componentItems = list( productItemId = arguments.productItemId );

		for ( var item in componentItems ) {
			item.setTypeId( "own" );
			data.add( item );
		}

		// components of attribute of productItem
		var productItem = getProductItemService().get( arguments.productItemId );

		if ( Len( productItem.getAttributeValue().getId() ) ) {
			var attrComponents = list( attributeValueId = productItem.getAttributeValue().getId() );

			for ( var thisComponent in attrComponents ) {
				
				// thisComponent is ComponentAttributeValue
				// move to ComponentProductItem

				var bean = super.bean("ComponentProductItem");
				
				bean.setRawMemento( thisComponent.getRawMemento() );
				bean.setProductItem( productItem );
				bean.setTypeId( "base" );

				var override = getComponentOverrideService().list( productItem.getId(), thisComponent.getId() );

				if ( override.len() ) {
					// TODO: should be only one override. Add check? db guarantees uniqueness

					bean.setOverride( override[ 1 ] );
				}

				data.add( bean );
			}
		}

		result.setData( data );
		result.setCount( data.len() );
		result.setTotal( data.len() );

		return result;
	}

	private Array function searchByProductItemIdForPriceCalculator( required String productItemId ){
		var data   = [];
		var result = getResult();

		// components of productItem
		var componentItems = getDao().find( "productItemId" = arguments.productItemId )

		for ( var item in componentItems ) {
			var componentItem = getDao().priceCalculatorRead( componentId = item.component_id, productItemId = arguments.productItemId );
			data.add(componentItem)
		}

		// components of attribute of productItem
		var productItem = getProductItemDAO().read( arguments.productItemId );

		if ( Len( productItem.attribute_raw_value_id ) ) {
			var attributeValueId = productItem.attribute_raw_value_id[1]
			var attributeComponents = priceCalculatorSearch( attributeValueId = attributeValueId )
			if (Len(attributeComponents))
			for (var attributeComponent in attributeComponents) {
				data.add(attributeComponent)
			}
		}
		
		return data;
	}

	/*
    	private method
	*/

	// TODO: di fatto avrebbe più senso sia searchByAttributeValueId, ma per ora lo lascio così
	private com.apirone.core.model.bean.Result function searchByProductItemIdOld( required String productItemId ){
		var data   = [];
		var result = getResult();

		// components of productItem
		var componentItems = list( productItemId = arguments.productItemId );

		for ( var item in componentItems ) {
			item.setTypeId( "own" );
			data.add( item );
		}

		// components of attribute of productItem
		var productItem = getProductItemService().get( arguments.productItemId );

		if ( Len( productItem.getAttributeValue().getId() ) ) {
			var attrComponents = list( attributeValueId = productItem.getAttributeValue().getId() );

			for ( var thisComponent in attrComponents ) {
				
				// thisComponent is ComponentAttributeValue
				// move to ComponentProductItem

				var bean = super.bean("ComponentProductItem");
				
				bean.setRawMemento( thisComponent.getRawMemento() );
				bean.setProductItem( productItem );
				bean.setTypeId( "base" );

				var override = getComponentOverrideService().list( productItem.getId(), thisComponent.getId() );

				if ( override.len() ) {
					// TODO: should be only one override. Add check? db guarantees uniqueness

					bean.setOverride( override[ 1 ] );
				}

				data.add( bean );
			}
		}

		result.setData( data );
		result.setCount( data.len() );
		result.setTotal( data.len() );

		return result;
	}

	/**
	 * Recupera in batch più Component dato un array di ID.
	 * Restituisce uno Struct chiave = componentId, valore = bean Component.
	 * precarica ProductItem, Product, SignageConfigItem, Line e Model in batch
	 * per evitare il problema N+1 nei rami condizionali di buildFromRow().
	 *
	 * @ids Array di componentId
	 * @return Struct mappato per componentId -> Component
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie gli ID delle FK dai rami condizionali
		var productItemIds       = [];
		var productIds           = [];
		var signageConfigItemIds = [];
		var lineIds              = [];
		var modelIds             = [];

		for ( var r in records ) {
			// ProductItem (sia join_id che product_item_id)
			if ( Val( r.product_item_id ) ) {
				productItemIds.append( r.product_item_id );
			}
			if ( Len( r.product_item_join_id ) ) {
				productItemIds.append( r.product_item_join_id );
			}

			// Product
			if ( Len( r.product_id ) ) {
				productIds.append( r.product_id );
			}

			// SignageConfigItem (sia signage_config_item_id che join)
			if ( Len( r.signage_config_item_id ) ) {
				signageConfigItemIds.append( r.signage_config_item_id );
			}
			if ( Len( r.signage_config_item_join_id ) ) {
				signageConfigItemIds.append( r.signage_config_item_join_id );
			}

			// CatalogBundle
			if ( Len( r.line_id ) ) {
				lineIds.append( r.line_id );
			}
			if ( Len( r.model_id ) ) {
				modelIds.append( r.model_id );
			}
		}

		// Precarica i ProductItem in batch con getMany() ottimizzato
		var productItemMap = {};
		if ( ArrayLen( productItemIds ) ) {
			productItemMap = getProductItemService().getMany( productItemIds );
		}

		// Precarica i Product in batch con getMany() ottimizzato di ProductService
		var productMap = {};
		if ( ArrayLen( productIds ) ) {
			productMap = getProductService().getMany( productIds );
		}

		// Precarica i SignageConfigItem in batch (getMany esiste)
		var signageConfigItemMap = {};
		if ( ArrayLen( signageConfigItemIds ) ) {
			signageConfigItemMap = getSignageConfigItemService().getMany( signageConfigItemIds );
		}

		// Precarica le Line in batch (getMany esiste)
		var lineMap = {};
		if ( ArrayLen( lineIds ) ) {
			lineMap = getLineService().getMany( lineIds );
		}

		// Precarica i Model in batch (getMany esiste)
		var modelMap = {};
		if ( ArrayLen( modelIds ) ) {
			modelMap = getModelService().getMany( modelIds );
		}

		// Costruisce i bean Component con le mappe pre-caricate
		for ( var r in records ) {
			var bean = super.bean( "Component" );

			// Rami condizionali: determina il tipo di Component
			if ( Len( r.signage_config_item_join_id ) && Len( r.product_item_join_id ) ) {
				bean = super.bean( "ComponentSignageItemProduct" );

				if ( StructKeyExists( productItemMap, r.product_item_join_id ) ) {
					bean.setProductItem( productItemMap[ r.product_item_join_id ] );
				}
				if ( StructKeyExists( signageConfigItemMap, r.signage_config_item_join_id ) ) {
					bean.setSignageConfigItem( signageConfigItemMap[ r.signage_config_item_join_id ] );
				}
			} else if ( Val( r.product_item_id ) ) {
				bean = super.bean( "ComponentProductItem" );

				if ( StructKeyExists( productItemMap, r.product_item_id ) ) {
					bean.setProductItem( productItemMap[ r.product_item_id ] );
				}
			} else if ( Len( r.product_id ) ) {
				bean = super.bean( "ComponentProduct" );

				if ( StructKeyExists( productMap, r.product_id ) ) {
					bean.setProduct( productMap[ r.product_id ] );
				}
			} else if ( Len( r.signage_config_item_id ) ) {
				bean = super.bean( "ComponentSignageConfigItem" );

				if ( StructKeyExists( signageConfigItemMap, r.signage_config_item_id ) ) {
					bean.setSignageConfigItem( signageConfigItemMap[ r.signage_config_item_id ] );
				}
			} else if ( Len( r.line_id ) && Len( r.model_id ) ) {
				bean = super.bean( "ComponentCatalogBundle" );

				if ( StructKeyExists( lineMap, r.line_id ) ) {
					bean.setLine( lineMap[ r.line_id ] );
				}
				if ( StructKeyExists( modelMap, r.model_id ) ) {
					bean.setModel( modelMap[ r.model_id ] );
				}
			}

			// Campi comuni
			bean.setId( r.component_id );
			bean.setQuantity( r.quantity );
			bean.setCreatedAt( r.created_at );
			bean.setStatus( getStatusService().get( r.status_id ) );
			bean.setOverride( super.bean( "ComponentOverride" ) );

			// Verticale: rawProduct, variant, color e cost caricati individualmente (cache interna)
			if ( request.loadFromVerticale ) {
				bean.setRawProduct( getRawProductService().get( r.raw_product_id ) );
				bean.setVariant( getVariantService().get( r.variant_id ) );
				bean.setColor( getColorService().get( r.color_id ) );

				// CostService.getByParams() richiede i bean già impostati
				if ( !IsNull( bean.getRawProduct() ) && !IsNull( bean.getVariant() ) && !IsNull( bean.getColor() ) ) {
					var cost = getCostService().getByParams(
						rawProductId = bean.getRawProduct().getId(),
						variantId    = bean.getVariant().getId(),
						colorId      = bean.getColor().getId()
					);
					bean.setCost( cost );
				}
			}

			map[ r.component_id ] = bean;
		}

		return map;
	}

	/**
	 * Costruisce un bean Component a partire dall'ID. Delega a buildFromRow() dopo la lettura del record.
	 */
	private com.apirone.core.model.bean.Component function build( required String componentId ){
		var record = getDao().read( arguments.componentId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Component a partire da una riga del query.
	 * Le sub-entity (ProductItem, Product, SignageConfigItem, Line, Model, ecc.) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.Component function buildFromRow( required any record ){
		// TODO: factory for all Component*
		var bean   = super.bean( "Component" );
	    var kindId = "CP";

		if ( Len( arguments.record.signage_config_item_join_id ) AND Len( arguments.record.product_item_join_id ) ) {
			bean = super.bean( "ComponentSignageItemProduct" );

			bean.setProductItem( getProductItemService().get( arguments.record.product_item_join_id ) );
			bean.setSignageConfigItem( getSignageConfigItemService().get( arguments.record.signage_config_item_join_id ) );

			kindId = "PS";
		}

		if ( Val( arguments.record.product_item_id ) ) {

			bean = super.bean( "ComponentProductItem" );
			bean.setProductItem( getProductItemService().get( arguments.record.product_item_id ) );
			kindId = "PI";
		}

		if ( Len( arguments.record.product_id ) ) {
			bean = super.bean( "ComponentProduct" );
			bean.setProduct( getProductService().get( arguments.record.product_id ) );
			kindId = "PR";
		}

		if ( Len( arguments.record.signage_config_item_id ) ) {
			bean = super.bean( "ComponentSignageConfigItem" );
			bean.setSignageConfigItem( getSignageConfigItemService().get( arguments.record.signage_config_item_id ) );
			kindId = "SI";
		}

		if ( Len( arguments.record.line_id ) AND Len( arguments.record.model_id ) ) {
			bean = super.bean( "ComponentCatalogBundle" );

			bean.setLine( getLineService().get( arguments.record.line_id ) );
			bean.setModel( getModelService().get( arguments.record.model_id ) );
			kindId = "CB";
		}

		bean.setId( arguments.record.component_id );

		// TODO: move to bean
		//bean.setKindId( kindId );

		if ( request.loadFromVerticale ) {
			bean.setRawProduct( getRawProductService().get( arguments.record.raw_product_id ) );
			bean.setVariant( getVariantService().get( arguments.record.variant_id ) );
			bean.setColor( getColorService().get( arguments.record.color_id ) );
		}

		bean.setQuantity( arguments.record.quantity );
		bean.setCreatedAt( arguments.record.created_at );

		bean.setStatus( getStatusService().get( arguments.record.status_id ) );

		// changes to Override are updated at runtime
		bean.setOverride( super.bean( "ComponentOverride" ) );

		var cost = getCostService().getByParams(
			rawProductId = bean.getRawProduct().getId(),
			variantId    = bean.getVariant().getId(),
			colorId      = bean.getColor().getId()
		);

		bean.setCost( cost );

		return bean;
	}

}
