component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="PricelistDAO";
	property name="cacheScope" type="String" default="Pricelist.bean";

	public com.apirone.core.model.bean.Pricelist function get( required String pricelistId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.pricelistId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.pricelistId );
		cm.put( getCacheScope(), arguments.pricelistId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return read( argumentCollection = arguments ).getData()
	}

	private com.apirone.core.model.bean.Result function read(
		String pricelistId,
		required Numeric limit  = 20,
		required Numeric offset = 0
	){
		var rows   = [];
		var result = super.getResult();

		var records = getDao().read( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( pricelistId = record.pricelist_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );

		return result;
	}

	private com.apirone.core.model.bean.Pricelist function build( required String pricelistId ){
		var record = getDao().read( arguments.pricelistId );

		if ( record.RecordCount ) {
			var obj = super.bean( "Pricelist" );
			obj.setId( record.pricelist_id.toString() );
			obj.setName( record.pricelist );
			return obj;
		}

		return NullValue();
	}

}
