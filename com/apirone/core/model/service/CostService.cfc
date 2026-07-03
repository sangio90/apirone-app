component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="CostDAO";

	public com.apirone.core.model.bean.Cost function getByParams(
		required String rawProductId,
		String required variantId="",
		String required colorId=""
	){
		/*
			TODO: performance note
				We could cache the result with the key with the combination of
				product_id, color_id, variant_id. But the query is already in the cache.
		*/

		var q    = "";
		var bean = super.bean( "Cost" );

		// if ( rawProductId == "LAV-VERNPOLVMET" AND arguments.variantId == "VE-BINS" ) {
		q = getDao().read( argumentCollection = arguments );

		if ( q.recordcount ) {
			getLogger().info( "CostService. Get cost for rawProductId [#arguments.rawProductId#], variantId [#arguments.variantId#], colorId [#arguments.colorId#] found: #q.lispre#" )
			return bean.setAmount( q.lispre );
		}

		q = getDao().read( rawproductId = arguments.rawProductId, variantId = arguments.variantId );

		if ( q.recordcount ) {
			getLogger().info( "CostService. Get cost for rawProductId [#arguments.rawProductId#], variantId [#arguments.variantId#] found: #q.lispre#" );
			return bean.setAmount( q.lispre );
		}

		q = getDao().read( rawproductId = arguments.rawProductId, colorId = arguments.colorId );

		if ( q.recordcount ) {
			getLogger().info( "CostService. Get cost for rawProductId [#arguments.rawProductId#], colorId [#arguments.colorId#] found: #q.lispre#" );
			return bean.setAmount( q.lispre );
		}

		q = getDao().read( rawproductId = arguments.rawProductId );

		if ( q.recordcount ) {
			getLogger().info( "CostService. Get cost for rawProductId [#arguments.rawProductId#] found cost: #q.lispre#" );
			return bean.setAmount( q.lispre );
		}

		getLogger().info( "CostService. Get cost for rawProductId [#arguments.rawProductId#], variantId [#arguments.variantId#], colorId [#arguments.colorId#] NOT found. Return 0" );
		// }

		return bean.setAmount( 0 );
	}

}
