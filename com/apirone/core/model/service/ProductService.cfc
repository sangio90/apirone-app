component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ProductDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
    property name="productTypeService" type="com.apirone.core.model.service.ProductTypeService";
    property name="ColorService" type="com.apirone.core.model.service.ColorService";
    property name="VariantService" type="com.apirone.core.model.service.VariantService";
    property name="LookupService" type="com.apirone.core.model.service.LookupService";

    public com.apirone.core.model.bean.Product function get(
    		required String productId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.productId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.productId );
		
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
			rows.add( get( productId = record.arcodart ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }


    /*
    	private method
	*/

	private com.apirone.core.model.bean.Product function build(
    		required String productId
    	){

	    var record = getDao().read( arguments.productId );

	    if( record.recordCount ) { 

			var record = trimQueryFields( record );

            var bean = super.bean( "Product" );

            bean.setId( record.arcodart );
			bean.setName( record.ardesart );
			bean.setType( getProductTypeService().get( record.artipmat )  );
			bean.setProcessingType( getLookupService().get( "processingType", record.processiong_type_id )  );

			var variants = getVariantService().list( productId=record.arcodart );
			var colors = getColorService().list( productId=record.arcodart );

			/*
			if( !variants.len() ) {
				var variant =  super.bean("Variant");
				
				variant.setId("_NOVAR");
				variant.setName("Nessuna variante");

				variants.add( variant );
			}

			if( !colors.len() ) {

				var color =  super.bean("Color");
				
				color.setId("_NOCOL");
				color.setName("Nessun colore");

				colors.add( color );

			}
			*/

			for( var thisVariant in variants ) {
				thisVariant.setColors( colors )
			}

			bean.setVariants( variants );
			
            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "Product_#arguments.id#";

  	}

}
