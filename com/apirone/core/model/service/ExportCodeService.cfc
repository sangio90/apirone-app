component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ExportCodeDAO";

	property name="cacheScope" type="String" default="ExportCode.bean";

	public com.apirone.core.model.bean.ExportCode function get( required Numeric exportCodeId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.exportCodeId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.exportCodeId );
		cm.put( getCacheScope(), arguments.exportCodeId, bean );

		return bean;
	}

	public Numeric function max(
		String exportCode
	){
		return getDao().max( argumentCollection = arguments );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		Numeric productHashId,
		required Numeric limit    = 15,
		required Numeric offset   = 0,
		required Array orderBy    = [ { field = "exportCode.id" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( exportCodeId = record.export_code_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric exportCodeId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.exportCodeId );

		outcome.setData( { exportCodeId = arguments.exportCodeId } );
		getDao().delete( arguments.exportCodeId );

		transaction {
			try {
				var cm = getCacheManager();

				getDao().delete( arguments.exportCodeId );

				cm.remove( getCacheScope(), arguments.exportCodeId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteExportCode" );
				outcome.setMessage( "Cannot delete Export Code [#arguments.exportCodeId#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.ExportCode exportCode ){
		return getDao().insert( arguments.exportCode );
	}

	public String function update( required com.apirone.core.model.bean.ExportCode exportCode ){
		getDao().update( arguments.exportCode );
		super.getCacheManager().remove( getCacheScope(), arguments.exportCode.getId() );

		return arguments.exportCode.getId();
	}

	private com.apirone.core.model.bean.ExportCode function build( required Numeric exportCodeId ){
		var record = getDao().read( arguments.exportCodeId );

		if ( record.recordCount ) {
			var bean = super.bean( "ExportCode" );
			bean.setId( record.export_code_id );
			bean.setName( record.export_code );
			bean.setCounter( record.counter );
			bean.setProductHashId( record.product_hash_id );

			return bean;
		}

		return NullValue();
	}

}
