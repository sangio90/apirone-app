component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="CostDAO";
	property name="lookupService" inject="lookupService";

	property name="cacheScope" type="String" default="Price.bean";

	public com.apirone.core.model.bean.Price function get( required String priceId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.priceId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.priceId );
		cm.put( getCacheScope(), arguments.priceId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String productId,
		Numeric productItemId,
		String statusId
	){
		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( record.price_id, false ) );
		} );

		result.setData( rows );
		result.setTotal( Val( records.total ) );
		result.setCount( Val( records.recordcount ) );

		return result;
	}


}
