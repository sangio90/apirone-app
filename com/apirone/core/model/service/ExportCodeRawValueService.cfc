component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ExportCodeRawValueDAO";
	property name="RawValueService" inject="RawValueService";
	property name="AttributeService" inject="AttributeService";
	property name="ExportCodeService" inject="ExportCodeService";

	property name="cacheScope" type="String" default="ExportCodeRawValue.bean";

	public com.apirone.core.model.bean.ExportCodeRawValue function get( required Numeric exportCodeRawValueId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.exportCodeRawValueId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.exportCodeRawValueId );
		cm.put( getCacheScope(), arguments.exportCodeRawValueId, bean );

		return bean;
	}

	public com.apirone.core.model.bean.ExportCodeRawValue function getByParams(
		Numeric rawValueId
	){
		var record = getDao().find( argumentCollection = arguments );

		if ( record.recordcount == 1 ) {
			return get( record.export_code_raw_value_id );
		}

		return NullValue();
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		Numeric rawValueId,
		required Numeric limit    = 15,
		required Numeric offset   = 0,
		required Array orderBy    = [ { field = "exportCodeRawValue.id" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( exportCodeRawValueId = record.export_code_raw_value_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric exportCodeRawValueId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.exportCodeRawValueId );

		outcome.setData( { exportCodeRawValueId = arguments.exportCodeRawValueId } );
		getDao().delete( arguments.exportCodeRawValueId );

		transaction {
			try {
				var cm = getCacheManager();

				getDao().delete( arguments.exportCodeRawValueId );

				cm.remove( getCacheScope(), arguments.exportCodeRawValueId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteExportCodeRawValue" );
				outcome.setMessage( "Cannot delete Export Code [#arguments.exportCodeRawValueId#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.ExportCodeRawValue exportCodeRawValue ){
		return getDao().insert( exportCodeRawValue );
	}

	public String function update( required com.apirone.core.model.bean.ExportCodeRawValue exportCodeRawValue ){
		getDao().update( exportCodeRawValue );

		super.getCacheManager().remove( getCacheScope(), exportCodeRawValue.getId() );

		return exportCodeRawValue.getId();
	}

	private com.apirone.core.model.bean.ExportCodeRawValue function build( required Numeric exportCodeRawValueId ){
		var record = getDao().read( arguments.exportCodeRawValueId );

		if ( record.recordCount ) {
			var bean = super.bean( "ExportCodeRawValue" );
			bean.setId( record.export_code_raw_value_id );
			bean.setExportCode( getExportCodeService().get( record.export_code_id ) );
			bean.setRawValue( getRawValueService().get( record.raw_value_id ) );
			bean.setAttribute( getAttributeService().get( record.attribute_id ) );
			bean.setImportant( record.important );

			return bean;
		}

		return NullValue();
	}

}
