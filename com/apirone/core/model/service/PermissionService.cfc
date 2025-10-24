component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="lookupservice" type="lookupservice";
	
	property name="cacheScope" type="String" default="Permission.bean";

	public com.apirone.core.model.bean.Permission function get( required String priceId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.priceId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.priceId );
		cm.put( getCacheScope(), arguments.priceId, bean );

		return bean;
	}

	public com.apirone.core.model.bean.Result function list(
		String productId,
		Numeric productItemId,
		String statusId
	){

		var rows = FileRead( "/path/file" );

		result.setData( rows );
		result.setTotal( Val( records.total ) );
		result.setCount( Val( records.recordcount ) );

		return result;
	}


	private com.apirone.core.model.bean.Permission function build( required String priceId ){
		

		if ( record.recordCount ) {
			var bean = super.bean( "Price" );

			bean.setId( record.price_id );

			bean.setName( record.amount );
			bean.setEntity( lookupservice.get( "ENTITY", value ) );
			
			return bean;
		}

		return NullValue();
	}

}
