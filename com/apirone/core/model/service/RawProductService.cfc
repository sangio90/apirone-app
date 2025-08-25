component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="RawProductDAO";
	property name="statusService" inject="StatusService";
	property name="rawProductTypeService" inject="RawProductTypeService";
	property name="ColorService" inject="ColorService";
	property name="VariantService" inject="VariantService";
	property name="LookupService" inject="LookupService";

	property name="cacheScope" type="String" default="RawProduct.bean";

	public com.apirone.core.model.bean.RawProduct function get( required String rawProductId ){
		var cm = super.getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.rawProductId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.rawProductId );

		cm.put( getCacheScope(), arguments.rawProductId, bean );

		return bean;
	}

	public com.apirone.core.model.bean.Result function search(
		String typeId,
		String processingTypeId,
		String str,
		required Numeric limit  = 20,
		required Numeric offset = 0
	){
		if ( Len( arguments.processingTypeId ) AND !ListFind( "LV,MP", arguments.processingTypeId ) ) {
			Throw(
				type    = "apirone.error.valueNotAllowed",
				message = "The value [#arguments.processingTypeId#] for processingTypeId is not valid. The allowed values are LV=lavorazioni or MP=materie prime."
			);
		}

		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( rawProductId = record.arcodart ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.RawProduct function build( required String rawProductId ){
		var record = getDao().read( arguments.rawProductId );

		if ( record.recordCount ) {
			var record = super.trimQueryFields( record );

			var bean = super.bean( "RawProduct" );

			var misurementValue = Len( record.arunmis1 ) ? record.arunmis1 : "PZ";

			bean.setId( record.arcodart );
			bean.setName( record.ardesart );
			bean.setType( getRawProductTypeService().get( record.artipmat ) );
			bean.setProcessingType( getLookupService().get( "processingType", record.processiong_type_id ) );
			bean.setMeasurementUnit( getLookupService().get( "measurementUnit", misurementValue ) );

			var variants = getVariantService().list( rawProductId = record.arcodart );

			var colors = getColorService().list( rawProductId = record.arcodart );

			if ( !variants.len() ) {
				var variant = super.bean( "Variant" );

				variant.setId( "_NOVAR" );
				variant.setName( "Nessuna variante" );

				variants.add( variant );
			}

			if ( !colors.len() ) {
				var color = super.bean( "Color" );

				color.setId( "_NOCOL" );
				color.setName( "Nessun colore" );

				colors.add( color );
			}

			var colorVariants = []

			for ( var thisVariant in variants ) {
				// remove reference
				var newVariant = Duplicate( thisVariant );

				newVariant.setColors( colors );
				colorVariants.add( newVariant );
			}

			bean.setVariants( colorVariants );

			return bean;
		}

		return NullValue();
	}

}
