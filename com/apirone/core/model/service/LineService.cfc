component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="LineDAO";
	property name="statusService" inject="StatusService";
	property name="lookupService" inject="LookupService";
	property name="ProductCategoryService" inject="ProductCategoryService";
	property name="ProductItemService" inject="ProductItemService";
	property name="ProductService" inject="ProductService";
	property name="ComponentService" inject="ComponentService";
	property name="textService" inject="TextService";

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

	public String function create( required com.apirone.core.model.bean.Line line ){
		var newId = getDao().insert( arguments.line );

		transaction {
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

	public Struct function clone(
		required String fromLineId,
		required String toLineId,
		required Numeric categoryId
	){
		// recursive function to create product items
		function createProductItem(
			required String productId,
			required Struct productItem,
			required Numeric level = 1
		){
			arguments.productItem.setProductId( arguments.productId );

			var components       = getComponentService().list( productItemId = productItem.getId() );
			var newProductItemId = getProductItemService().create( arguments.productItem );

			var productItem = getProductItemService().get( newProductItemId );

			for ( var component in components ) {
				var newComponent = Duplicate( component );

				newComponent.setId( "" );
				newComponent.getProductItem().setId( newProductItemId );

				getComponentService().create( newComponent );
			}

			if ( arguments.productItem.getChildren().len() ) {
				for ( var child in arguments.productItem.getChildren() ) {
					child.getParent().setId( newProductItemId );

					createProductItem(
						productItem = child,
						level       = arguments.level + 1,
						productId   = arguments.productId
					);
				}
			}
		}

		getProductService().deleteAllByParams( lineId = arguments.toLineId, categoryId = arguments.categoryId );

		var products = getProductService().list( lineId = fromLineId, categoryId = categoryId );

		for ( var product in products ) {
			var item = Duplicate( product );
			item.getLine().setId( arguments.toLineId );

			var newId        = getProductService().create( item );
			var productItems = getProductItemService().getTree( productId = product.getId() );

			for ( productItem in productItems ) {
				createProductItem(
					productItem = productItem,
					level       = 1,
					productId   = newId
				);
			}
		}

		getCacheManager().removeAll();

		return {
			status  = "success",
			payload = {
				fromLineId = arguments.fromLineId,
				toLineId   = arguments.toLineId,
				categoryId = arguments.categoryId
			}
		};
	}

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

	public com.apirone.core.model.bean.Outcome function delete( required String lineId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.lineId );

		outcome.setData( { lineId = arguments.lineId } );

		transaction {
			try {
				var result = getDao().delete( arguments.lineId );
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

			bean.setTexts( getTextService().list( lineId = record.line_id ) );

			// after setTexts()
			bean.setName( bean.getName() );

			bean.setId( record.line_id );
			bean.setCode( record.code );
			bean.setCreatedAt( record.created_at );

			bean.setThickness( getLookupService().get( "thickness", record.thickness_id ) );
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setCategories( super.getCategoriesBeanByIds( record.categories ) );

			return bean;
		}

		return NullValue();
	}

}
