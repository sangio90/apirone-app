component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="VariantTypeDAO";

	property name="scopeCache" type="String" default="VariantType.bean";

	public com.apirone.core.model.bean.VariantType function get( required String variantTypeId ){
		var cm = super.getCacheManager();

		var cache = cm.get( getScopeCache(), arguments.variantTypeId );

		if ( cache.status ) {
			return cache.data;
		}

		var obj = build( arguments.variantTypeId );
		cm.put( getScopeCache(), arguments.variantTypeId, obj );

		return obj;
	}

	public String function create( required com.apirone.core.model.bean.VariantType variantType ){
		return getDao().insert( variantType = arguments.variantType );
	}

	public com.apirone.core.model.bean.Result function list( Boolean withNoVariant ){
		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( record.variant_type_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.VariantType function build( required String variantTypeId ){
		var record = getDao().read( arguments.variantTypeId );

		if ( record.RecordCount ) {
			var obj = super.bean( "VariantType" );

			obj.setId( record.variant_type_id.toString() );
			obj.setName( record.variant_type );

			return obj;
		}

		return NullValue();
	}

}
