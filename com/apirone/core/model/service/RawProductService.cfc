component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ProductDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
    property name="rawProductTypeService" type="com.apirone.core.model.service.RawProductTypeService";
    property name="ColorService" type="com.apirone.core.model.service.ColorService";
    property name="VariantService" type="com.apirone.core.model.service.VariantService";
    property name="LookupService" type="com.apirone.core.model.service.LookupService";

    public com.apirone.core.model.bean.RawProduct function get(
    		required String rawProductId
        ){

    	var cm = super.getCacheManager();

    	var key = getCacheKey( arguments.rawProductId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {

	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.rawProductId );

		cm.put( key, bean );
        
		return bean;

	}

    public com.apirone.core.model.bean.Result function search(
					String typeId,
					String processingTypeId,
					String str,
			required Numeric limit = 20,
			required Numeric offset = 0
    	){

		if( !ListFind( "LV,MP", arguments.processingTypeId ) ) {
			throw( type="ApirOne.errors.valueNotAllowed", message="For processingTypeId the allowed values are LV=lavorazioni or MP=materie prime" );
		}

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( rawProductId = record.arcodart ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }


    /*
    	private method
	*/

	private com.apirone.core.model.bean.RawProduct function build(
    		required String rawProductId
    	){

	    var record = getDao().read( arguments.rawProductId );

	    if( record.recordCount ) { 

			var record = super.trimQueryFields( record );

            var bean = super.bean( "RawProduct" );

			var misurementValue = Len( record.arunmis1 ) ? record.arunmis1 : "PZ";

            bean.setId( record.arcodart );
			bean.setName( record.ardesart );
			bean.setType( getRawProductTypeService().get( record.artipmat )  );
			bean.setProcessingType( getLookupService().get( "processingType", record.processiong_type_id ) );
			bean.setMeasurementUnit( getLookupService().get( "measurementUnit", misurementValue ) );

			var variants = getVariantService().list( rawProductId=record.arcodart );
			
			var colors = getColorService().list( rawProductId=record.arcodart );

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

			var colorVariants = []

			for( var thisVariant in variants ) {

				// remove reference
				var newVariant = Duplicate( thisVariant );

				newVariant.setColors( colors );
				colorVariants.add( newVariant );
			}

			bean.setVariants( colorVariants );
			
            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "RawProduct_#arguments.id#";

  	}

}
