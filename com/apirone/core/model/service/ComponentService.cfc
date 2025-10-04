component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ComponentDAO";
	property name="statusService" inject="StatusService";
	property name="rawProductService" inject="RawProductService";
	property name="variantService" inject="VariantService";
	property name="colorService" inject="ColorService";
	property name="productService" inject="ProductService";
	property name="productItemService" inject="ProductItemService";
	property name="componentOverrideService" inject="ComponentOverrideService";
	property name="lineService" inject="LineService";
	property name="modelService" inject="ModelService";
	property name="costService" inject="CostService";

	property name="cacheScope" type="String" default="Component.bean";

	public com.apirone.core.model.bean.Component function get( required String componentId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.componentId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.componentId );
		cm.put( getCacheScope(), arguments.componentId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
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

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( record.component_id, false ) );
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
			super.getCacheManager().remove( getCacheScope(), record.component_id );
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
				super.getCacheManager().remove( "Component_#obj.getId()#" );
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

				super.getCacheManager().remove( getCacheScope(), obj.getId() );
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

		super.getCacheManager().remove( getCacheScope(), component.getId() );

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
				var bean = Duplicate( thisComponent )

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

	private com.apirone.core.model.bean.Component function build( required String componentId ){
		var record = getDao().read( arguments.componentId );

		if ( record.recordCount ) {
			// TODO: factory for all Component*
			var bean = super.bean( "Component" );
			var kindId = "CP";

			if ( Len( record.product_item_id ) ) {
				bean = super.bean( "ComponentProductItem" );
				bean.setProductItem( getProductItemService().get( record.product_item_id ) );
				kindId = "PI";
			}

			if ( Len( record.product_id ) ) {
				bean = super.bean( "ComponentProduct" );
				bean.setProduct( getProductService().get( record.product_id ) );
				kindId = "PR";
			}

			if ( Len( record.line_id ) AND Len( record.model_id ) ) {
				bean = super.bean( "ComponentCatalogBundle" );

				bean.setLine( getLineService().get( record.line_id ) );
				bean.setModel( getModelService().get( record.model_id ) );
				kindId = "CB";
			}

			bean.setId( record.component_id );
			bean.setKindId( kindId );

			if ( request.loadFromVerticale ) {
				bean.setRawProduct( getRawProductService().get( record.raw_product_id ) );
				bean.setVariant( getVariantService().get( record.variant_id ) );
				bean.setColor( getColorService().get( record.color_id ) );
			}

			bean.setQuantity( record.quantity );
			bean.setCreatedAt( record.created_at );

			bean.setStatus( getStatusService().get( record.status_id ) );

			// changes to Override are updated at runtime
			bean.setOverride( super.bean( "ComponentOverride" ) );

			// changes to Override are updated at runtime

			var cost = getCostService().getByParams( 
							rawProductId = bean.getRawProduct().getId(),
							variantId    = bean.getVariant().getId(),
							colorId      = bean.getColor().getId()
						);



			bean.setCost(  );

			return bean;
		}

		return NullValue();
	}

}
