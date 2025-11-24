component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="CurrencyDAO";
	property name="cacheScope" type="String" default="Currency.bean";

	public com.apirone.core.model.bean.Currency function get( required String currencyId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.currencyId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.currencyId );
		cm.put( getCacheScope(), arguments.currencyId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return read( argumentCollection = arguments ).getData()
	}

	private com.apirone.core.model.bean.Result function read(
		String currencyId,
		required Numeric limit  = 20,
		required Numeric offset = 0
	){
		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( currencyId = record.currency_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );

		return result;
	}

	private com.apirone.core.model.bean.Currency function build( required String currencyId ){
		var record = getDao().read( arguments.currencyId );

		if ( record.RecordCount ) {
			var obj = super.bean( "Currency" );

			obj.setId( record.currency_id.toString() );
			obj.setName( record.currency );

			return obj;
		}

		return NullValue();
	}

}
