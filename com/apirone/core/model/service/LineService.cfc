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

		super.logEvent(
			event   = "line.created",
			message = "Line [#newId#] created",
			payload = { "id" = newId }
		);

		return newId;
	}

	public Struct function clone(
		required String fromLineId,
		required String toLineId,
		required Numeric categoryId
	){
		var payload = {
			"fromLineId" = arguments.fromLineId,
			"toLineId"   = arguments.toLineId,
			"categoryId" = arguments.categoryId
		};

		super.logEvent(
			event   = "line.CLONED",
			message = "Start clone line from [#arguments.fromLineId#] to [#arguments.toLineId#]",
			payload = payload
		);

		var productService   = getProductService();
		var componentService = getComponentService();


		var toLineId = arguments.toLineId;

		productService.deleteAllByParams( lineId = toLineId, categoryId = arguments.categoryId );

		var products = productService.list( lineId = arguments.fromLineId, categoryId = arguments.categoryId );

		cffile( action="APPEND" file="#ExpandPath('{web-root-directory}/debug.log')#" output="#now()# clone: productCount: #products.len()#");

		super.eachParallelAndReorder(
			sourceArray      = products,
			callbackFunction = function( product, index ) {
				var newProduct = Duplicate( product );
				newProduct.getLine().setId( toLineId );

				var newId = productService.create( newProduct );

				cffile( action="APPEND" file="#ExpandPath('{web-root-directory}/debug.log')#" output="#now()# clone: each: #product.getId()#");

				// duplicate components of product
				var productComponents = componentService.list( productId = product.getId() );

				for ( var itemProductComponent in productComponents ) {
					var newProductComponent = Duplicate( itemProductComponent );

					newProductComponent.setId( "" );
					newProductComponent.getProduct().setId( newId );

					componentService.create( newProductComponent );
				}

				// clone all productItems and components
				productService.cloneTree( fromProductId = product.getId(), toProductId = newId, deleteCache = false );

				return true;
			},
			maxThreads = 1
		);

		getCacheManager().removeAll();

		super.logEvent(
			event   = "line.CLONED",
			message = "End clone line from [#arguments.fromLineId#] to [#arguments.toLineId#]",
			payload = payload
		);

		return { "status" = "success", "payload" = payload };
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

		super.logEvent(
			event   = "line.updated",
			message = "Line [#arguments.line.getId()#] updated",
			payload = { "id" = arguments.line.getId() }
		);

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

				// super.logAction( type = "LINE.DELETED", message = "Line [#arguments.lineId#] deleted" );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteLine" );
				outcome.setMessage( "Cannot delete line [#arguments.lineId#]" );
			}
		}

		super.logEvent(
			event   = "line.deleted",
			message = "Line [#arguments.lineId#] deleted",
			payload = { "id" = arguments.lineId }
		);

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
			bean.setHscode( record.hscode );
			bean.setCreatedAt( record.created_at );

			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setCategories( super.getCategoriesBeanByIds( record.categories ) );

			return bean;
		}

		return NullValue();
	}

}
