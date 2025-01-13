component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.CombinationComponentDAO";
    property name="colorService" type="com.apirone.core.model.service.ColorService";
    property name="variantService" type="com.apirone.core.model.service.VariantService";
    property name="componentService" type="com.apirone.core.model.service.ComponentService";

    public com.apirone.core.model.bean.CombinationComponent function get(
    		required Numeric combinationComponentId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.combinationComponentId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.combinationComponentId );
		
		cm.put( key, bean );
        
		return bean;

	}


	public com.apirone.core.model.bean.CombinationComponent[] function list(
		String combinationComponentId,
	) {
		arguments["limit"] = -1;
		return search(argumentCollection = arguments).getData();
	}


    public com.apirone.core.model.bean.Result function search(
                     Numeric combinationItemId,
			required Numeric limit = 20,
			required Numeric offset = 0
    	){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( combinationComponentId = record.combination_item_component_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }


    /*
    	private method
	*/

	private com.apirone.core.model.bean.Component function build(
    		required String componentId
    	){

	    var record = getDao().read( arguments.componentId );

	    if( record.recordCount ) { 

            var bean = super.bean( "CombinationComponent" );

            bean.setId( record.combination_item_component_id );
            bean.setQuantity( record.quantity );
			
            bean.setComponent( getComponentService().get( record.component_id ) );
			bean.setVariant( getVariantService().get( record.variant_id ) );
			bean.setColor( getColorService().get( record.color_id ) );

            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required Numeric id ) {

  		return "CombinationComponent_#arguments.id#";

  	}

}
