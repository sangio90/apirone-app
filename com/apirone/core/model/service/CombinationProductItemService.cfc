component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="CombinationProductItemDAO";
	property name="ProductItemService" inject="ProductItemService";
	property name="CombinationService" inject="CombinationService";
	property name="ProductService" inject="ProductService";

	public com.apirone.core.model.bean.CombinationProductItem function get( required String combinationId ){
		return build( arguments.combinationId );
	}

	public com.apirone.core.model.bean.Result function getByCombinationId( required String combinationId ){
		var rows   = [];
		var result = super.getResult();

		// Recupera i record completi dal DAO
		var records = getDao().getByCombinationId( arguments.combinationId );

		// Raccoglie gli ID e carica i bean in blocco con getMany()
		var ids = [];
		records.each( function( record ){
			ids.append( record.combination_product_item_id );
		} );

		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine originale
		records.each( function( record ){
			rows.add( beanMap[ record.combination_product_item_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.recordcount ) );

		return result;
		;
	}

	/**
	 * Recupera in batch più CombinationProductItem dato un array di ID.
	 * Restituisce uno Struct chiave = combinationProductItemId, valore = bean CombinationProductItem.
	 * Precarica i ProductItem in batch locale per evitare il problema N+1.
	 *
	 * @ids Array di combinationProductItemId
	 * @return Struct mappato per combinationProductItemId -> CombinationProductItem
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie tutti i product_item_id per il precaricamento batch
		var productItemIds = [];
		for ( var record in records ) {
			if ( !IsNull( record.product_item_id ) ) {
				productItemIds.append( record.product_item_id );
			}
		}

		// Precarica tutti i ProductItem con una sola chiamata batch
		var productItemMap = ArrayLen( productItemIds )
			? getProductItemService().getMany( productItemIds )
			: {};

		for ( var record in records ) {
			var bean = super.bean( "CombinationProductItem" );

			// Campi diretti dal record
			bean.setId( record.combination_product_item_id );
			bean.setCreatedAt( record.created_at );
			bean.setCombinationId( record.combination_id );

			// ProductItem: dalla mappa pre-caricata in batch
			if ( StructKeyExists( productItemMap, record.product_item_id ) ) {
				bean.setProductItem( productItemMap[ record.product_item_id ] );
			}

			map[ bean.getId() ] = bean;
		}

		return map;
	}

	/**
	 * Recupera in batch i CombinationProductItem raggruppati per combination_id.
	 * Restituisce uno Struct chiave = combinationId, valore = Array di bean CombinationProductItem.
	 * Utilizzato da CombinationService.getMany() per evitare l'N+1 di getByCombinationId().
	 *
	 * @combinationIds Array di combinationId
	 * @return Struct mappato per combinationId -> Array[CombinationProductItem]
	 */
	public Struct function listByCombinationIds( required Array combinationIds ){
		var records = getDao().readByCombinationIds( arguments.combinationIds );
		var result  = {};

		// Raccoglie tutti i PK e carica i bean completi con getMany()
		var ids = [];
		for ( var record in records ) {
			ArrayAppend( ids, record.combination_product_item_id );
		}

		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Raggruppa i bean per combination_id
		for ( var id in ids ) {
			if ( !StructKeyExists( beanMap, id ) ) {
				continue;
			}
			var bean           = beanMap[ id ];
			var combinationId  = bean.getCombinationId();

			if ( !StructKeyExists( result, combinationId ) ) {
				result[ combinationId ] = [];
			}
			ArrayAppend( result[ combinationId ], bean );
		}

		return result;
	}

	public Array function list(){
		// TODO: check formatter
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Outcome function delete( required String combinationId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { combinationId = arguments.combinationId } );

		transaction {
			try {
				getDao().delete( arguments.combinationId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteCombination" );
				outcome.setMessage( "Cannot delete combinationProductItem [#arguments.combinationId#]" );
			}
		}

		return outcome;
	}


	public String function create(
		required com.apirone.core.model.bean.CombinationProductItem combinationProductItem
	){
		var newId = getDao().insert( arguments.combinationProductItem );

		if ( !IsNull( arguments.combinationProductItem.getTexts() ) ) {
			transaction {
				for ( var text in arguments.combinationProductItem.getTexts() ) {
					var entity = super.bean( "Entity" );

					entity.setKey( "combinationProductItem.id" );
					entity.setValue( newId );

					text.setEntity( entity );
				}

				getTextService().bulkCreate( arguments.combinationProductItem.getTexts() );
			}
		}

		return newId;
	}


	public String function update(
		required com.apirone.core.model.bean.CombinationProductItem combinationProductItem
	){
		getDao().update( arguments.combinationProductItem );

		var id = arguments.combinationProductItem.getId();

		if ( !IsNull( arguments.combinationProductItem.getTexts() ) ) {
			for ( var text in arguments.combinationProductItem.getTexts() ) {
				var entity = super.bean( "Entity" )

				entity.setKey( "combinationProductItem.id" );
				entity.setValue( id );

				text.setEntity( entity );

				if ( Len( text.getId() ) ) {
					getTextService().update( text );
				} else {
					getTextService().create( text );
				}
			}
		}

		return arguments.combinationProductItem.getId();
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.CombinationProductItem function build(
		required String combinationProductItemId
	){
		var record = getDao().read( arguments.combinationProductItemId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean CombinationProductItem a partire da una riga del query.
	 * La sub-entity ProductItem è caricata con chiamata individuale.
	 */
	private com.apirone.core.model.bean.CombinationProductItem function buildFromRow(
		required any record
	){
		var bean = super.bean( "CombinationProductItem" );

		// Campi diretti dal record
		bean.setId( record.combination_product_item_id );
		bean.setCreatedAt( record.created_at );
		bean.setCombinationId( record.combination_id );

		// Entity collegate (caricate singolarmente)
		var productItem = getProductItemService().get( record.product_item_id );
		bean.setProductItem( productItem );

		return bean;
	}

}
