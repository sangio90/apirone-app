component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ComponentOverrideDAO";

	public com.apirone.core.model.bean.ComponentOverride function get( required String ComponentOverrideId ){
		return build( arguments.ComponentOverrideId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		required Numeric productItemId,
		required Numeric componentId
	){
		var rows   = [];
		var result = super.getResult();

		// TODO: should be only one override with productItemId and componentId.
		// Add check? DB guarantees uniqueness

		// Il find() restituisce gli ID: li raccogliamo e carichiamo i record in una sola query
		var records = getDao().find( argumentCollection = arguments );

		var ids = [];
		records.each( function( r ){
			ids.append( r.component_override_id );
		} );

		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );
			allRecords.each( function( record ){
				rows.add( buildFromRow( record ) );
			} );
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String ComponentOverrideId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.ComponentOverrideId );

		outcome.setData( { ComponentOverrideId = arguments.ComponentOverrideId } );

		transaction {
			try {
				getDao().delete( arguments.ComponentOverrideId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteComponentOverride" );
				outcome.setMessage( "Cannot delete ComponentOverride [#arguments.ComponentOverrideId#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.ComponentOverride ComponentOverride ){
		var id = getDao().insert( arguments.ComponentOverride );

		return id;
	}


	public String function update( required com.apirone.core.model.bean.ComponentOverride ComponentOverride ){
		getDao().update( arguments.ComponentOverride );

		return arguments.ComponentOverride.getId();
	}

	private com.apirone.core.model.bean.ComponentOverride function build( required String ComponentOverrideId ){
		var record = getDao().read( arguments.ComponentOverrideId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean ComponentOverride a partire da una riga della query.
	 */
	private com.apirone.core.model.bean.ComponentOverride function buildFromRow( required any record ){
		var bean = super.bean( "ComponentOverride" );

		// Campi diretti dal record (ComponentOverride non ha sub-entity)
		bean.setId( record.component_override_id );
		bean.setDeleted( record.deleted );
		bean.setQuantity( record.quantity );
		bean.setCreatedAt( record.created_at );

		return bean;
	}

}
