component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="LineCostDAO";
	property name="lineService" inject="LineService";
	property name="finishService" inject="FinishService";
	property name="productCategoryService" inject="ProductCategoryService";
	property name="productItemService" inject="ProductItemService";

	public com.apirone.core.model.bean.LineCost function get( required Numeric lineCostId ){
		return build( arguments.lineCostId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		Numeric categoryId,
		String lineId,
		String finishId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "linecost.line_code", desc = "asc" }, { field = "linecost.finish_code", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( r ){
			ids.append( r.line_cost_id );
		} );

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.line_cost_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/**
	 * Recupera in batch più LineCost dato un array di ID.
	 * Restituisce uno Struct chiave = lineCostId, valore = bean LineCost.
	 * Precarica Line, Finish e Category in batch per evitare il problema N+1.
	 *
	 * @ids Array di lineCostId
	 * @return Struct mappato per lineCostId -> LineCost
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie tutti gli ID delle FK da precaricare in batch
		var lineIds     = [];
		var finishIds   = [];
		var categoryIds = [];

		for ( var record in records ) {
			if ( !IsNull( record.line_id ) ) {
				lineIds.append( record.line_id );
			}
			if ( !IsNull( record.finish_id ) ) {
				finishIds.append( record.finish_id );
			}
			if ( !IsNull( record.product_category_id ) ) {
				categoryIds.append( record.product_category_id );
			}
		}

		// Precarica le entity FK con getMany() esistenti (1 query ciascuna)
		var lineMap = {};
		if ( ArrayLen( lineIds ) ) {
			lineMap = getLineService().getMany( lineIds );
		}

		var finishMap = {};
		if ( ArrayLen( finishIds ) ) {
			finishMap = getFinishService().getMany( finishIds );
		}

		var categoryMap = {};
		if ( ArrayLen( categoryIds ) ) {
			categoryMap = getProductCategoryService().getMany( categoryIds );
		}

		// Costruisce i bean con le mappe pre-caricate
		for ( var record in records ) {
			var bean = super.bean( "LineCost" );

			// Campi diretti dal record
			bean.setId( record.line_cost_id );
			bean.setCost( record.cost );

			// Entity collegate dalle mappe pre-caricate
			if ( StructKeyExists( lineMap, record.line_id ) ) {
				bean.setLine( lineMap[ record.line_id ] );
			}

			if ( StructKeyExists( finishMap, record.finish_id ) ) {
				bean.setFinish( finishMap[ record.finish_id ] );
			}

			if ( StructKeyExists( categoryMap, record.product_category_id ) ) {
				bean.setCategory( categoryMap[ record.product_category_id ] );
			}

			map[ record.line_cost_id ] = bean;
		}

		return map;
	}

	public String function create( required com.apirone.core.model.bean.LineCost lineCost ){
		transaction {
			var newId = getDao().insert( arguments.lineCost );
		}

		super.logEvent(
			event   = "lineCost.created",
			message = "LineCost [#newId#] created",
			payload = { "id" = newId }
		);

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.LineCost lineCost ){

		getDao().update( arguments.lineCost );

		var id = arguments.lineCost.getId();

		super.logEvent(
			event   = "lineCost.updated",
			message = "LineCost [#arguments.lineCost.getId()#] updated",
			payload = { "id" = arguments.lineCost.getId() }
		);

		return arguments.lineCost.getId();
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric lineCostId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.lineCostId );

		outcome.setData( { lineCostId = arguments.lineCostId } );

		transaction {
			try {
				var result = getDao().delete( arguments.lineCostId );
				outcome.setData( { "deletedCount" = result } )
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteLine" );
				outcome.setMessage( "Cannot delete lineCost [#arguments.lineCostId#]" );
			}
		}

		super.logEvent(
			event   = "lineCost.deleted",
			message = "LineCost [#arguments.lineCostId#] deleted",
			payload = { "id" = arguments.lineCostId }
		);

		return outcome;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.LineCost function build( required Numeric lineCostId ){
		var record = getDao().read( arguments.lineCostId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean LineCost a partire da una riga della query.
	 * Le sub-entity (Line, Finish, Category) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.LineCost function buildFromRow( required any row ){
		var bean = super.bean( "LineCost" );

		// Campi diretti dal record
		bean.setId( arguments.row.line_cost_id );
		bean.setCost( arguments.row.cost );

		// Entity collegate (caricate singolarmente)
		bean.setLine( getLineService().get( arguments.row.line_id ) );
		bean.setFinish( getFinishService().get( arguments.row.finish_id ) );
		bean.setCategory( getProductCategoryService().get( arguments.row.product_category_id ) );

		return bean;
	}

}
