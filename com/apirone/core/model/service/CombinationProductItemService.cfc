component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="CombinationProductItemDAO";
	property name="ProductItemService" inject="ProductItemService";
	property name="CombinationService" inject="CombinationService";
	property name="ProductService" inject="ProductService";
	property name="cacheScope" type="String" default="CombinationProductItem.bean";

	public com.apirone.core.model.bean.CombinationProductItem function get( required String combinationId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.combinationId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.combinationId );
		cm.put( getCacheScope(), arguments.combinationId, bean );

		return bean;
	}

	public com.apirone.core.model.bean.Result function getByCombinationId( required String combinationId ){
		var rows   = [];
		var result = super.getResult();

		var records = getDao().getByCombinationId( arguments.combinationId );

		records.each( function( record ){
			rows.add( get( record.combination_product_item_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.recordcount ) );

		return result;;
	}

	public Array function list(){
		// TODO: check formatter
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Outcome function delete( required String combinationId ){
		var combinationProductItem = super.bean( "CombinationProductItem" );

		var obj = get( arguments.combinationId );

		outcome.setData( { combinationId = arguments.combinationId } );
		getDao().delete( arguments.combinationId );

		transaction {
			try {
				var cm = getCacheManager();

				getDao().delete( arguments.combinationId );

				cm.remove( getCacheScope(), arguments.combinationId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteCombination" );
				outcome.setMessage( "Cannot delete combinationProductItem [#arguments.combinationId#]" );
			}
		}

		return outcome;
	}


	public String function create( required com.apirone.core.model.bean.CombinationProductItem combinationProductItem ){
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


	public String function update( required com.apirone.core.model.bean.CombinationProductItem combinationProductItem ){
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

		super.getCacheManager().remove( getCacheScope(), arguments.combinationProductItem.getId() );

		return arguments.combinationProductItem.getId();
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.CombinationProductItem function build( required String combinationProductItemId ){
		var record = getDao().read( arguments.combinationProductItemId );

		if ( record.recordCount ) {
			var bean = super.bean( "CombinationProductItem" );

			bean.setId( record.combination_id );
			bean.setCreatedAt( record.created_at );
			bean.setProductItemId( record.product_item_id );
			bean.setCombinationId( record.combination_id );

			var productItem = getProductItemService().get( record.product_item_id );
			bean.setProductItem( productItem );

			return bean;
		}

		return NullValue();
	}
}
