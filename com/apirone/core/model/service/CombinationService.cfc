component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="CombinationDAO";
	property name="combinationProductItemDao" inject="CombinationProductItemDAO";
	property name="ProductItemService" inject="ProductItemService";
	property name="CombinationProductItemService" inject="CombinationProductItemService";
	property name="ProductService" inject="ProductService";
	property name="statusService" inject="StatusService";
	property name="cacheScope" type="String" default="Combination.bean";

	public com.apirone.core.model.bean.Combination function get( required String combinationId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.combinationId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.combinationId );
		cm.put( getCacheScope(), arguments.combinationId, bean );

		return bean;
	}

	// TODO: use search( productId )
	public com.apirone.core.model.bean.Result function getByProductId( required String productId ){
		var rows   = [];
		var result = super.getResult();

		var records = getDao().getByProductId( arguments.productId );

		records.each( function( record ){
			rows.add( get( record.combination_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.recordcount ) );

		return result;
	}

	public Array function calculateCombinations( required String productId ){
		var items = getProductItemService().getFlatTree(
			productId            = arguments.productId,
			includeMissingValues = false
		);
		// Trasformo il flat tree in un array di righe
		var rows = flattenTreeToRows( items );

		// Costruisco l'albero delle combinazioni di prodotti cartesiani ricorsivi

		var tree = buildTree( rows );
		tree     = parseTree( tree );

		for ( var node in tree ) {
			var combinationAlreadyExists = getCombinationProductItemDao().exists( node );

			if ( combinationAlreadyExists ) {
				// loggo che la combinazione esiste già
				getLogger().info( "Combination already exists for node: " & SerializeJSON( node ) );
				continue; // Se la combinazione esiste già, salto al prossimo nodo
			}

			// Cerco se esiste già una combinazione per il prodotto

			var combination = super.bean( "Combination" );
			combination.setProductId( arguments.productId );
			combination.setStatus( getStatusService().get( "ACT" ) );

			var combinationId = create( combination );

			for ( var productItemId in node ) {
				var item    = super.bean( "CombinationProductItem" );
				var product = super.bean( "productItem" );

				item.setCombinationId( combinationId );
				item.setProductItem( product.setId( productItemId ) );

				getCombinationProductItemService().create( item );
			}
		}
		// Converto l'albero in un array di combinazioni uniche

		// TODO: message with number of combinations created
		var combinations = [];
		return combinations;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String combinationId ){
		var outcome = super.bean( "Outcome" );

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
				outcome.setMessage( "Cannot delete combination [#arguments.combinationId#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.Combination combination ){
		var newId = getDao().insert( arguments.combination );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.Combination combination ){
		getDao().update( arguments.combination );

		super.getCacheManager().remove( getCacheScope(), arguments.combination.getId() );

		return arguments.combination.getId();
	}


	/*
    	private method
	*/

	// Inizio helper per calcolo ricorsione
	private function buildTree( rows ){
		var tree  = [];
		var stack = [];

		for ( row in rows ) {
			var node = {
				id       = row.id,
				attr     = row.attr,
				value    = row.value,
				level    = row.level,
				children = []
			};

			// Pulisce lo stack oltre il livello corrente
			if ( ArrayLen( stack ) >= node.level ) {
				for ( i = ArrayLen( stack ); i >= node.level; i-- ) {
					ArrayDeleteAt( stack, i );
				}
			}

			if ( node.level == 1 ) {
				ArrayAppend( tree, node );
			} else {
				var parent = stack[ node.level - 1 ];
				ArrayAppend( parent.children, node );
			}

			stack[ node.level ] = node;
		}

		return tree;
	}

	// Ricorsione: genera tutte le combinazioni per un nodo e i suoi figli
	private function expandCombinations( node ){
		var combinations = [];

		if ( ArrayLen( node.children ) == 0 ) {
			// Nessun figlio → solo il nodo stesso
			combinations = [ [ node.id ] ];
		} else {
			var childCombos = [];
			for ( child in node.children ) {
				childCombos.append( expandCombinations( child ), true );
			}

			// Aggiunge il nodo attuale a ogni combinazione figlia
			for ( combo in childCombos ) {
				ArrayPrepend( combo, node.id );
				ArrayAppend( combinations, combo );
			}
		}

		return combinations;
	}

	// Combina le combinazioni da nodi con attributi diversi
	private function combineIndependentTrees( groups ){
		if ( ArrayLen( groups ) == 0 ) return [];

		var result = groups[ 1 ];

		for ( var i = 2; i <= ArrayLen( groups ); i++ ) {
			var newResult = [];
			for ( var a in result ) {
				for ( var b in groups[ i ] ) {
					var combined = Duplicate( a );
					for ( var id in b ) {
						ArrayAppend( combined, id );
					}
					ArrayAppend( newResult, combined );
				}
			}
			result = newResult;
		}

		return result;
	}

	private function flattenTreeToRows(
		nodes,
		level = 1,
		rows  = []
	){
		for ( var node in nodes ) {
			var row = {
				id    = node.getId(),
				attr  = node.getAttribute().getId(),
				value = node.getAttributeValue().getId(),
				level = node.getLevel()
			};

			ArrayAppend( rows, row );
		}

		return rows;
	}

	private function parseTree( tree ){
		// 1. Raggruppa i nodi di livello 1 per ATTR
		var groupedLevel1 = StructNew();
		for ( var node in tree ) {
			if ( !StructKeyExists( groupedLevel1, node.attr ) ) {
				groupedLevel1[ node.attr ] = [];
			}
			ArrayAppend( groupedLevel1[ node.attr ], node );
		}

		// 2. Per ogni gruppo (ATTR diverso), espandi tutte le combinazioni valide
		var perAttrCombinations = [];
		for ( var attr in groupedLevel1 ) {
			var attrCombinations = [];

			for ( var node in groupedLevel1[ attr ] ) {
				attrCombinations.append( expandCombinations( node ), true );
			}

			ArrayAppend( perAttrCombinations, attrCombinations );
		}

		// 3. Combina tutte le combinazioni tra ATTR diversi
		var validCombinations = combineIndependentTrees( perAttrCombinations );

		// 4. Rimuove duplicati
		var uniqueSet          = StructNew();
		var uniqueCombinations = [];

		for ( var combo in validCombinations ) {
			var key = ArrayToList( combo, "," );
			if ( !StructKeyExists( uniqueSet, key ) ) {
				StructInsert( uniqueSet, key, true );
				ArrayAppend( uniqueCombinations, combo );
			}
		}
		return uniqueCombinations;
	}
	// Fine helper per calcolo ricorsione

	private com.apirone.core.model.bean.Combination function build( required String combinationId ){
		var record = getDao().read( arguments.combinationId );

		if ( record.recordCount ) {
			var bean = super.bean( "Combination" );

			bean.setId( record.combination_id );
			bean.setCreatedAt( record.created_at );
			bean.setProductId( record.product_id );
			bean.setStatus( getStatusService().get( record.status_id ) );

			var combinationProductItems = getCombinationProductItemService().getByCombinationId(
				record.combination_id
			);

			var productItemsData = combinationProductItems.getData();

			bean.setProductItems( productItemsData );

			var name = "";

			productItemsData.each( function( combinationProductItem, index ){
				name &= combinationProductItem
					.getProductItem()
					.getAttribute()
					.getName();

				name &= ": ";

				name &= combinationProductItem
					.getProductItem()
					.getAttributeValue()
					.getRawValue()
					.getName();

				name &= productItemsData.len() == index ? "" : " - ";
			} );

			bean.setName( name );

			return bean;
		}

		return NullValue();
	}

}
