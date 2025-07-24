component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ComponentDAO";
	property name="statusService" inject="StatusService";
	property name="rawProductService" inject="RawProductService";
	property name="variantService" inject="VariantService";
	property name="colorService" inject="ColorService";
	property name="productItemService" inject="ProductItemService";
	property name="ComponentOverrideService" inject="ComponentOverrideService";

	property name="cacheScope" type="String" default="Component.bean";

	/*
	property name="attributeService" inject="AttributeService";
	property name="attributeValueService" inject="AttributeValueService";
	property name="productComponentService" inject="ProductComponentService";
    */

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
		String sizeId,
		String productId,
		Numeric productItemId,
		Numeric attributeValueId
	){
		var result = getDao().find( argumentCollection = arguments );

		return Val( result.total );
	}

	public com.apirone.core.model.bean.Result function search(
		String lineId,
		String sizeId,
		String productId,
		Numeric productItemId,
		Numeric attributeValueId,
		Boolean includeBaseAttributeComponents = false hint="Only for product productItemId"
	){
		cffile(
			action = "APPEND",
			file   = "#ExpandPath( "/debug.log" )#",
			output = "#Now()# search: start: #arguments.productItemId#"
		);

		if ( !IsNull( arguments.productItemId ) AND arguments.includeBaseAttributeComponents ) {
			return searchByProductItemId( arguments.productItemId );
			// cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# search: searchByProductItemId: #arguments.productItemId#");
		}

		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( record.component_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.recordcount ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String componentId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.componentId );

		outcome.setData( { componentId = arguments.componentId } );

		transaction {
			try {
				getDao().delete( arguments.componentId );

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

	public String function create( required com.apirone.core.model.bean.Component component ){
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
			var bean = super.bean( "Component" );

			bean.setId( record.component_id );

			bean.setRawProduct( getRawProductService().get( record.raw_product_id ) );

			bean.setVariant( getVariantService().get( record.variant_id ) );
			bean.setColor( getColorService().get( record.color_id ) );

			bean.setQuantity( record.quantity );
			bean.setCreatedAt( record.created_at );

			bean.setStatus( getStatusService().get( record.status_id ) );

			// changes to Override are updated at runtime
			bean.setOverride( super.bean( "ComponentOverride" ) );

			return bean;
		}

		return NullValue();
	}

}
