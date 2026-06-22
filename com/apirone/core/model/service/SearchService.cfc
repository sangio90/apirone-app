component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="SearchDAO";
	property name="productService" inject="ProductService";

	public com.apirone.core.model.bean.SearchTerm function get( required String searchTermId ){
		return build( arguments.searchTermId );
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "line.code", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Il find() restituisce tutte le colonne: si raccolgono gli ID per getMany()
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie gli ID e carica i bean in blocco con getMany()
		var ids = [];
		records.each( function( record ){
			ids.append( record.search_term_id );
		} );

		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.search_term_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/**
	 * Recupera in batch più SearchTerm dato un array di ID.
	 * Restituisce uno Struct chiave = searchTermId, valore = bean SearchTerm.
	 * Precarica i Product in batch locale per evitare il problema N+1.
	 *
	 * @ids Array di searchTermId
	 * @return Struct mappato per searchTermId -> SearchTerm
	 */
	public Struct function getMany( required Array ids ){
		var records  = getDao().readByIds( ids = arguments.ids );
		var map      = {};
		var products = {};

		for ( var record in records ) {
			var bean = super.bean( "SearchTerm" );

			// Campi diretti dal record
			bean.setId( record.search_term_id );
			bean.setTerm( record.search_term );
			bean.setCreatedAt( record.created_at );

			// Product: cached localmente per evitare chiamate N+1
			if ( !StructKeyExists( products, record.product_id ) ) {
				products[ record.product_id ] = getProductService().get( record.product_id );
			}
			bean.setProduct( products[ record.product_id ] );

			map[ bean.getId() ] = bean;
		}

		return map;
	}

	/*
    	private method
	*/

	/**
	 * Costruisce un bean SearchTerm a partire dall'ID. Delega a buildFromFindRow() dopo la lettura del record.
	 */
	private com.apirone.core.model.bean.SearchTerm function build( required String searchTermId ){
		var record = getDao().read( arguments.searchTermId );

		if ( record.recordCount ) {
			return buildFromFindRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean SearchTerm a partire da una riga della query.
	 * La sub-entity Product è caricata con chiamata individuale.
	 */
	private com.apirone.core.model.bean.SearchTerm function buildFromFindRow( required any record ){
		var bean = super.bean( "SearchTerm" );

		// Campi diretti dal record
		bean.setId( record.search_term_id );
		bean.setTerm( record.search_term );
		bean.setCreatedAt( record.created_at );

		// Entity collegata (Product è caricato singolarmente)
		bean.setProduct( getProductService().get( record.product_id ) );

		return bean;
	}

}
