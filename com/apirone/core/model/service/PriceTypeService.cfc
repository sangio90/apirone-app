component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="PriceTypeDAO";
	property name="statusService" inject="StatusService";

	public com.apirone.core.model.bean.PriceType function get( required String priceTypeId ){
		return build( arguments.priceTypeId );
	}

	public Boolean function idExists( required String id, String excludedId = "" ){
		var record = getDao().read( arguments.id );

		if (
			record.recordCount
		) {
			return record.price_type_id == arguments.id;
		}

		return false;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "priceType.id", desc = "asc" } ]
	){
		
		var rows   = [];
		var result = super.getResult();

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( record ){
			ids.append( record.price_type_id );
		} );

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.price_type_id ] );
		} );

		result.setData( rows );
		result.setTotal( Val( records.total ) );
		result.setCount( Val( records.recordcount ) );
		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String priceTypeId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.priceTypeId );

		outcome.setData( { priceTypeId = arguments.priceTypeId } );

		transaction {
			try {
				getDao().delete( arguments.priceTypeId );

				super.logEvent(
					event   = "price_type.deleted",
					message = "Price type [#arguments.priceTypeId#] deleted.",
					payload = { "id" = arguments.priceTypeId }
				);
			
			} catch ( any error ) {

				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeletePriceType" );
				outcome.setMessage( "Cannot delete price type [#arguments.priceTypeId#]" );
			
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.PriceType priceType ){

		var id = getDao().insert( arguments.priceType );

		return id;
	}


	public String function update( required com.apirone.core.model.bean.PriceType priceType ){
		getDao().update( arguments.priceType );

		return arguments.priceType.getId();
	}


	/*
    	private method
	*/

	/**
	 * Recupera in batch più PriceType dato un array di ID.
	 * Restituisce uno Struct chiave = priceTypeId, valore = bean PriceType.
	 * Precarica status, methods e entities con cache locale per evitare il problema N+1.
	 *
	 * @ids Array di priceTypeId
	 * @return Struct mappato per priceTypeId -> PriceType
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Cache locale per status
		var statuses = {};

		// Raccoglie tutti gli ID unici di methods e entities dai JSONB di ogni record
		var allMethodIds = [];
		var allEntityIds = [];
		for ( var record in records ) {
			var methods = IsNull( record.methods ) ? [] : DeserializeJSON( record.methods );
			if ( !IsNull( methods ) && ArrayLen( methods ) ) {
				for ( var mid in methods ) {
					allMethodIds.append( mid );
				}
			}

			var entities = IsNull( record.entities ) ? [] : DeserializeJSON( record.entities );
			if ( !IsNull( entities ) && ArrayLen( entities ) ) {
				for ( var eid in entities ) {
					allEntityIds.append( eid );
				}
			}
		}

		// Precarica tutti i methods bean da LookupService (in-memory) con cache locale
		var methodMap = {};
		for ( var mid in allMethodIds ) {
			if ( !StructKeyExists( methodMap, mid ) ) {
				methodMap[ mid ] = super.service( "lookup" ).get( "priceMethod", mid );
			}
		}

		// Precarica tutti gli entities bean da LookupService (in-memory) con cache locale
		var entityMap = {};
		for ( var eid in allEntityIds ) {
			if ( !StructKeyExists( entityMap, eid ) ) {
				entityMap[ eid ] = super.service( "Lookup" ).get( "entity", eid );
			}
		}

		for ( var record in records ) {
			var bean = super.bean( "PriceType" );

			// Campi diretti dal record
			bean.setId( record.price_type_id );
			bean.setName( record.price_type );
			bean.setCreatedAt( record.created_at );

			// Status: cached localmente
			if ( !StructKeyExists( statuses, record.status_id ) ) {
				statuses[ record.status_id ] = getStatusService().get( record.status_id );
			}
			bean.setStatus( statuses[ record.status_id ] );

			// Methods: dalle mappe pre-caricate
			var methods = IsNull( record.methods ) ? [] : DeserializeJSON( record.methods );
			var methodBeans = [];
			if ( !IsNull( methods ) && ArrayLen( methods ) ) {
				for ( var mid in methods ) {
					if ( StructKeyExists( methodMap, mid ) ) {
						methodBeans.append( methodMap[ mid ] );
					}
				}
			}
			bean.setMethods( ArrayLen( methodBeans ) ? methodBeans : NullValue() );

			// Entities: dalle mappe pre-caricate
			var entities = IsNull( record.entities ) ? [] : DeserializeJSON( record.entities );
			var entityBeans = [];
			if ( !IsNull( entities ) && ArrayLen( entities ) ) {
				for ( var eid in entities ) {
					if ( StructKeyExists( entityMap, eid ) ) {
						entityBeans.append( entityMap[ eid ] );
					}
				}
			}
			bean.setEntities( ArrayLen( entityBeans ) ? entityBeans : NullValue() );

			map[ record.price_type_id ] = bean;
		}

		return map;
	}

	private com.apirone.core.model.bean.PriceType function build( required String priceTypeId ){
		var record = getDao().read( arguments.priceTypeId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean PriceType a partire da una riga della query, senza chiamata DB aggiuntiva
	 * per il record principale.
	 */
	public com.apirone.core.model.bean.PriceType function buildFromRow( required any record ){
		var bean = super.bean( "PriceType" );

		// Campi diretti dal record
		bean.setId( record.price_type_id );
		bean.setName( record.price_type );
		bean.setCreatedAt( record.created_at );

		// Entity collegate (caricate singolarmente)
		bean.setStatus( getStatusService().get( record.status_id ) );
		bean.setMethods( super.getMethodsBeanByIds( record.methods ) );
		bean.setEntities( super.getEntitiesBeanByIds( record.entities ) );

		return bean;
	}

}
