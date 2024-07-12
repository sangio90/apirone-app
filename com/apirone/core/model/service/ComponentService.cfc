component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ComponentDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	//property name="ComponentAttributeService" type="com.apirone.core.model.service.ComponentVariantService";
    property name="ComponentTypeService" type="com.apirone.core.model.service.ComponentTypeService";
    property name="ColorService" type="com.apirone.core.model.service.ColorService";
    property name="VariantService" type="com.apirone.core.model.service.VariantService";
	//property name="variantTypeService" type="com.apirone.core.model.service.VariantTypeService";

    public com.apirone.core.model.bean.Component function get(
    		required String componentId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.componentId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.componentId );
		cm.put( key, bean );
        
		return bean;

	}

    public com.apirone.core.model.bean.Result function search(
			required Numeric limit = 20,
			required Numeric offset = 0
    	){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( componentId = record.arcodart ) );
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

			var record = trimQueryFields( record );

            var bean = super.bean( "Component" );

            bean.setId( record.arcodart );
			bean.setName( record.ardesart );
			bean.setType( getComponentTypeService().get( record.artipmat )  );
			bean.setVariants( getVariantService().list( componentId=record.arcodart )  );
			//bean.setColors( getColorService().list( componentId=record.arcodart )  );
			
            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "Component_#arguments.id#";

  	}

}
