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

	public com.apirone.core.model.bean.Line function get( required String lineId ){
		return build( arguments.lineId );
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

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );
		var ids     = [];
		records.each( function( r ){
			ids.append( r.line_id );
		} );

		var beanMap = {};

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );
			allRecords.each( function( r ){
				beanMap[ r.line_id ] = buildFromRow( r );
			} );
		}

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( r ){
			rows.add( beanMap[ r.line_id ] );
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

	/**
	 * Costruisce un bean Line a partire dall'ID, effettuando la lettura dal DB.
	 */
	private com.apirone.core.model.bean.Line function build( required String lineId ){
		var record = getDao().read( arguments.lineId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Line a partire da una riga della query.
	 * Utilizzato sia da build() (record singolo) che da search() (iterazione batch).
	 * Le sub-entity (thickness, texts, status, categories) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.Line function buildFromRow( required any record ){
		var bean = super.bean( "Line" );

		// Campi diretti dal record
		bean.setId( record.line_id );
		bean.setCode( record.code );
		bean.setHscode( record.hscode );
		bean.setCreatedAt( record.created_at );

		// Entity collegate (caricate singolarmente)
		bean.setThickness( getLookupService().get( "thickness", record.thickness_id ) );
		bean.setTexts( getTextService().list( lineId = record.line_id ) );
		bean.setName( bean.getName() );
		bean.setStatus( getStatusService().get( record.status_id ) );
		bean.setCategories( super.getCategoriesBeanByIds( record.categories ) );

		return bean;
	}

}
