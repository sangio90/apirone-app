component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.VariantDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="colorService" type="com.apirone.core.model.service.ColorService";

    public com.apirone.core.model.bean.Variant function get(
    		required String variantId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.variantId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.variantId );
		cm.put( key, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.Variant[] function list(
		String rawProductId,
	) {
		arguments["limit"] = -1;
		return search(argumentCollection = arguments).getData();
	}


    public com.apirone.core.model.bean.Result function search(
		             String rawProductId,
			required Numeric limit = 20,
			required Numeric offset = 0
    	){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( variantId = record.varcod ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }


    /*
    	private method
	*/

	private com.apirone.core.model.bean.Variant function build(
    		required String variantId
    	){

        var bean = super.bean( "Variant" );

		if( arguments.variantId == "_NOVAR" ) {
		
			bean.setId("_NOVAR");
			bean.setName("Nessuna variante");

			return bean;

		}

	    var record = getDao().read( arguments.variantId );

	    if( record.recordCount ) { 

			var record = trimQueryFields( record );

            bean.setId( record.varcod );
			bean.setName( record.vardes );

            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "Variant_#arguments.id#";

  	}

}
