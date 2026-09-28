component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="LineModelCostDAO";
	property name="lineService" inject="LineService";
	property name="modelService" inject="ModelService";
	property name="productCategoryService" inject="ProductCategoryService";

	public com.apirone.core.model.bean.LineModelCost function get( required Numeric lineModelCostId ){
		return build( arguments.lineModelCostId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		Numeric categoryId,
		String lineId,
		String modelId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "linemodelcost.line_code", desc = "asc" }, { field = "linemodelcost.model_code", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		var ids = [];
		records.each( function( r ){
			ids.append( r.line_model_cost_id );
		} );

		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.line_model_cost_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/**
	 * Recupera in batch più LineModelCost dato un array di ID.
	 * Precarica Line, Model e Category in batch per evitare il problema N+1.
	 *
	 * @ids Array di lineModelCostId
	 * @return Struct mappato per lineModelCostId -> LineModelCost
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		var lineIds     = [];
		var modelIds    = [];
		var categoryIds = [];

		for ( var record in records ) {
			lineIds.append( record.line_id );
			modelIds.append( record.model_id );
			categoryIds.append( record.product_category_id );
		}

		var lineMap     = ArrayLen( lineIds ) ? getLineService().getMany( lineIds ) : {};
		var modelMap    = ArrayLen( modelIds ) ? getModelService().getMany( modelIds ) : {};
		var categoryMap = ArrayLen( categoryIds ) ? getProductCategoryService().getMany( categoryIds ) : {};

		for ( var record in records ) {
			var bean = super.bean( "LineModelCost" );

			bean.setId( record.line_model_cost_id );
			bean.setCost( record.cost );

			if ( StructKeyExists( lineMap, record.line_id ) ) {
				bean.setLine( lineMap[ record.line_id ] );
			}

			if ( StructKeyExists( modelMap, record.model_id ) ) {
				bean.setModel( modelMap[ record.model_id ] );
			}

			if ( StructKeyExists( categoryMap, record.product_category_id ) ) {
				bean.setCategory( categoryMap[ record.product_category_id ] );
			}

			map[ record.line_model_cost_id ] = bean;
		}

		return map;
	}

	/**
	 * Combinazioni categoria/linea/modello esistenti a catalogo, come array di struct
	 * { categoryId, lineId, modelId }: alimentano le select a cascata della pagina.
	 */
	public Array function listCombinations(){
		var rows = [];

		for ( var record in getDao().listCombinations() ) {
			rows.append( {
				"categoryId" = record.product_category_id,
				"lineId"     = record.line_id,
				"modelId"    = record.model_id
			} );
		}

		return rows;
	}

	public String function create( required com.apirone.core.model.bean.LineModelCost lineModelCost ){
		transaction {
			var newId = getDao().insert( arguments.lineModelCost );
		}

		super.logEvent(
			event   = "lineModelCost.created",
			message = "LineModelCost [#newId#] created",
			payload = { "id" = newId }
		);

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.LineModelCost lineModelCost ){
		getDao().update( arguments.lineModelCost );

		super.logEvent(
			event   = "lineModelCost.updated",
			message = "LineModelCost [#arguments.lineModelCost.getId()#] updated",
			payload = { "id" = arguments.lineModelCost.getId() }
		);

		return arguments.lineModelCost.getId();
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric lineModelCostId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { lineModelCostId = arguments.lineModelCostId } );

		transaction {
			try {
				var result = getDao().delete( arguments.lineModelCostId );
				outcome.setData( { "deletedCount" = result } )
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteLineModelCost" );
				outcome.setMessage( "Cannot delete lineModelCost [#arguments.lineModelCostId#]" );
			}
		}

		super.logEvent(
			event   = "lineModelCost.deleted",
			message = "LineModelCost [#arguments.lineModelCostId#] deleted",
			payload = { "id" = arguments.lineModelCostId }
		);

		return outcome;
	}


	/*
		private method
	*/

	private com.apirone.core.model.bean.LineModelCost function build( required Numeric lineModelCostId ){
		var record = getDao().read( arguments.lineModelCostId );

		if ( record.recordCount ) {
			var map = getMany( [ arguments.lineModelCostId ] );
			return map[ record.line_model_cost_id ];
		}

		return NullValue();
	}

}
