component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="com.apirone.core.model.dao.ProductionTimeDAO";
	property name="statusService" inject="com.apirone.core.model.service.StatusService";

	public com.apirone.core.model.bean.ProductionTime function get( required String productionTimeId ){
		return build( arguments.productionTimeId );
	}

	public Boolean function codeExists( required String code, String excludeId = "" ){
		var products = search( code = arguments.code ).getData();

		return !IsNull( products[ 1 ] ) AND products[ 1 ].getId() NEQ arguments.excludeId
	}

	public com.apirone.core.model.bean.Result function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments );
	}

	public com.apirone.core.model.bean.Result function search(
		required Numeric limit  = 20,
		required Numeric offset = 0
	){
		var rows   = [];
		var result = super.getResult();

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i bean in blocco con getMany()
		var ids = [];
		records.each( function( record ){
			ids.append( record.production_time_id );
		} );

		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.production_time_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/**
	 * Recupera in batch più ProductionTime dato un array di ID.
	 * Restituisce uno Struct chiave = productionTimeId, valore = bean ProductionTime.
	 * Precarica lo Status in batch locale per evitare il problema N+1.
	 *
	 * @ids Array di productionTimeId
	 * @return Struct mappato per productionTimeId -> ProductionTime
	 */
	public Struct function getMany( required Array ids ){
		var records  = getDao().readByIds( ids = arguments.ids );
		var map      = {};
		var statuses = {};

		for ( var record in records ) {
			var bean = super.bean( "ProductionTime" );

			// Campi diretti dal record
			bean.setId( record.production_time_id );
			bean.setName( record.production_time );
			bean.setCreatedAt( record.created_at );

			// Status: cached localmente
			if ( !StructKeyExists( statuses, record.status_id ) ) {
				statuses[ record.status_id ] = getStatusService().get( record.status_id );
			}
			bean.setStatus( statuses[ record.status_id ] );

			map[ bean.getId() ] = bean;
		}

		return map;
	}

	public String function create( required com.apirone.core.model.bean.ProductionTime productionTime ){
		var newId = getDao().insert( arguments.productionTime );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.ProductionTime productionTime ){
		getDao().update( arguments.productionTime );

		var id = arguments.productionTime.getId();

		return id;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String productionTimeId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.productionTimeId );

		outcome.setData( { productionTimeId = arguments.productionTimeId } );

		transaction {
			try {
				var result = getDao().delete( arguments.productionTimeId );
				outcome.setData( { "deletedCount" = result } )
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteProductionTime" );
				outcome.setMessage( "Cannot delete productionTime [#arguments.productionTimeId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	/**
	 * Costruisce un bean ProductionTime a partire dall'ID. Delega a buildFromFindRow() dopo la lettura del record.
	 */
	private com.apirone.core.model.bean.ProductionTime function build( required String productionTimeId ){
		var record = getDao().read( arguments.productionTimeId );

		if ( record.recordCount ) {
			return buildFromFindRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean ProductionTime a partire da una riga della query.
	 */
	private com.apirone.core.model.bean.ProductionTime function buildFromFindRow( required any record ){
		var bean = super.bean( "ProductionTime" );

		// Campi diretti dal record
		bean.setId( record.production_time_id );
		bean.setName( record.production_time );

		// Entity collegate (Status è un lookup leggero)
		bean.setStatus( getStatusService().get( record.status_id ) );
		bean.setCreatedAt( record.created_at );

		return bean;
	}

}
