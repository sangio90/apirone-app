component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="VatCodeDAO";

	public com.apirone.core.model.bean.PaymentType function get( required String paymentTypeId ){
		var cm = getCacheManager();

		var cache = cm.get( key );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.paymentTypeId );
		cm.put( key, bean );

		return bean;
	}

	public com.apirone.core.model.bean.PaymentType(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		required Numeric limit  = 50,
		required Numeric offset = 0
	){
		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );

		for ( var record in records ) {
			rows.add( get( paymentTypeId = record.pagcod ) )
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/**
	 * @private
	 */
	private com.apirone.core.model.bean.PaymentType function build( required String paymentTypeId ){
		var record = getDao().read( paymentTypeId = arguments.paymentTypeId );

		var bean = NullValue();

		if ( record.RecordCount ) {
			var bean = super.bean( "VatCode" );

			bean.setId( record.pagcod );
			bean.setName( record.pagdes );
			// bean.setValue( record.ivaper );
		}

		return bean;
	}

}
