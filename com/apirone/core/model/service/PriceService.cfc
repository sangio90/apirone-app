component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="PriceDAO";
	property name="statusService" inject="StatusService";
	property name="productService" inject="ProductService";
	property name="productItemService" inject="ProductItemService";
	property name="priceTypeService" inject="PriceTypeService";
	property name="lookupService" inject="LookupService";
	property name="articleService" inject="ArticleService";

	public com.apirone.core.model.bean.Price function get( required String priceId ){
		return build( arguments.priceId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String productId,
		Numeric productItemId,
		String statusId,
		String articleId
	){
		var rows   = [];
		var result = super.getResult();

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( record ){
			ids.append( record.price_id );
		} );

		var beanMap = {};
		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );
			allRecords.each( function( record ){
				beanMap[ record.price_id ] = buildFromRow( record );
			} );
		}

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.price_id ] );
		} );

		result.setData( rows );
		result.setTotal( Val( records.total ) );
		result.setCount( Val( records.recordcount ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String priceId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.priceId );

		outcome.setData( { priceId = arguments.priceId } );

		transaction {
			try {
				getDao().delete( arguments.priceId );
				super.logEvent(
					event   = "price.deleted",
					message = "Price [#arguments.priceId#] deleted.",
					payload = { "id" = arguments.priceId }
				);
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.error.CannotDeletePrice" );
				outcome.setMessage( "Cannot delete price [#arguments.priceId#]" );
			}
		}

		return outcome;
	}

	public com.apirone.core.model.bean.Outcome function deleteByParams(
		required  com.apirone.core.model.bean.Price price
	){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.price.getId() );

		outcome.setData( { price = arguments.price } );

		transaction {
			try {
				getDao().deleteByParams( arguments.price );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeletePrice" );
				outcome.setMessage( "Cannot delete price [#obj.getId()#]" );
			}
		}

		return outcome;
	}

	public Numeric function create( required com.apirone.core.model.bean.Price price ){
		if ( IsNull( arguments.price.getEntity() ) ) {
			Throw( type = "Apirone.errors.EntityRequired", message = "Entity of price is required." );
		}

		var id = getDao().insert( arguments.price );

		return id;
	}

	public Numeric function update( required com.apirone.core.model.bean.Price price ){
		if ( IsNull( arguments.price.getEntity() ) ) {
			Throw( type = "Apirone.errors.EntityRequired", message = "Entity of price is required." );
		}

		getDao().update( arguments.price );

		return arguments.price.getId();
	}

	public Struct function massiveReassign(
		String categoryId,
		String modelId,
		String lineId,
		String finishId,
		String typeId, // price type
		String newMethodId,
		Numeric newAmount
	){
		var arg = arguments.typeId;

		var findCriteria = {
			"lineId"     = arguments.lineId,
			"categoryId" = arguments.categoryId,
			"modelId"    = arguments.modelId,
			"finishId"   = arguments.finishId
		};

		var rows   = [];
		var result = super.getResult();

		var updatedRecords  = 0;
		var insertedRecords = 0;

		backupTable( "prices" );

		var products = getProductService().list( argumentCollection = findCriteria );

		for ( var product in products ) {

			var prices = list( productId = product.getId(), typeId = arguments.typeId );

			if ( prices.len() ) {

				for ( var price in prices ) {
					var bean   = super.bean( "Price" );
					var entity = super.bean( "Entity" );

					entity.setKey( "product.id" );
					entity.setValue( product.getId() );

					var bean = get( price.getId() );

					bean.setAmount( arguments.newAmount );
					bean.setMethod( getLookupService().get( "priceMethod", arguments.newMethodId ) );

					bean.setEntity( entity );

					getDao().update( bean );

					updatedRecords++;

					super.logEvent(
						event   = "price.UPDATED",
						message = "Price [#price.getId()#] updated by mass update",
						payload = {
							"criteria" = findCriteria,
							"price"    = {
								"id"        = price.getId(),
								"typeId"    = price.getType().getId(),
								"productId" = product.getId(),
								"amount"    = price.getAmount(),
								"methodId"  = price.getMethod().getId()
							},
							"newAmount"   = arguments.newAmount,
							"newMethodId" = arguments.newMethodId
						}
					);
				}
			} else {
				var bean   = super.bean( "Price" );
				var entity = super.bean( "Entity" );

				bean.setAmount( arguments.newAmount );
				bean.setMethod( getLookupService().get( "priceMethod", arguments.newMethodId ) );
				bean.setType( getPriceTypeService().get( arguments.typeId ) );
				bean.setStatus( getStatusService().get( "ACT" ) );

				entity.setKey( "product.id" );
				entity.setValue( product.getId() );

				bean.setEntity( entity );

				var currentId = getDao().insert( bean );

				insertedRecords++;

				super.logEvent(
					event   = "price.CREATED",
					message = "Price [#currentId#] created by mass method.",
					payload = {
						"criteria"    = findCriteria,
						"price"       = { "newId" = currentId },
						"newAmount"   = arguments.newAmount,
						"newMethodId" = arguments.newMethodId
					}
				);
			}
		};

		return { "inserted" = insertedRecords, "updated" = updatedRecords };
	}



	/*
    	private method
	*/

	private com.apirone.core.model.bean.Price function build( required String priceId ){
		var record = getDao().read( arguments.priceId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Price a partire da una riga della query, senza chiamata DB aggiuntiva
	 * per il record principale.
	 */
	public com.apirone.core.model.bean.Price function buildFromRow( required any record ){
		var bean = super.bean( "Price" );

		// Campi diretti dal record
		bean.setId( record.price_id );
		bean.setAmount( record.amount );
		bean.setCreatedAt( record.created_at );

		// Entity collegate (caricate singolarmente)
		bean.setMethod( getLookupService().get( "priceMethod", record.method_id ) );
		bean.setType( getPriceTypeService().get( record.price_type_id ) );
		bean.setStatus( getStatusService().get( record.status_id ) );
		bean.setEntity( getEntity( record ) );

		return bean;
	}

	private com.apirone.core.model.bean.Entity function getEntity( required record ){
		var entity = super.bean( "Entity" );

		if ( Len( record.product_item_id ) ) {
			entity.setKey( "productItem.id" );
			entity.setValue( record.product_item_id );

			return entity;
		}

		if ( Len( record.product_id ) ) {
			entity.setKey( "product.id" );
			entity.setValue( record.product_id );

			return entity;
		}

		getLogger().error( "No entity linked to this price. Price Id: [#record.price_id#]" );

	}

	/**
	 * Recupera in batch tutti i prezzi collegati a una lista di productId.
	 * Restituisce uno Struct chiave = productId, valore = Array di bean Price.
	 * Sostituisce chiamate ripetute a list() per ogni prodotto.
	 *
	 * @productIds Array di productId
	 * @return Struct mappato per productId -> Array di Price
	 */
	public Struct function listByProductIds( required Array productIds ){
		var records = getDao().findByProductIds( productIds = arguments.productIds );
		var map     = {};

		// Raggruppa i risultati della query per productId
		for ( var record in records ) {
			var productId = record.product_id;
			if ( !StructKeyExists( map, productId ) ) {
				map[ productId ] = [];
			}
			var bean = buildFromRow( record );
			ArrayAppend( map[ productId ], bean );
		}

		return map;
	}

}
