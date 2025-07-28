component extends="com.apirone.core.controller.AbsController" {
	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var sizeConfigId = StructKeyExists(json, "sizeConfigId") && Len( json.sizeConfigId ) ? json.sizeConfigId : "";
		var sizeId = Len( json.sizeId ) ? json.sizeId : "";
		var lineId = Len( json.lineId ) ? json.lineId : "";
		var productCategoryId = Len( json.productCategoryId ) ? json.productCategoryId : "";
		var height = Len( json.height ) ? json.height : "";
		var width = Len( json.width ) ? json.width : "";


		if (sizeConfigId != "") {
			//TODO update
			var sizeConfig = super.service("SizeConfig").get( sizeConfigId );
			if ( IsNull(sizeConfig) ) {
				var message = completeMessage( "sizeConfig.notFound" );
				super.getResult().setError( message );
				event.setValue( "result", super.getResult() );
				return;
			}
			sizeConfig.setHeight( height );
			sizeConfig.setWidth( width );
			var updated = super.service("SizeConfig").update( sizeConfig );
		} else {
			//TODO create
			var sizeConfig = super.bean( "SizeConfig" );
			sizeConfig.setSize( super.service("Size").get( sizeId ));
			sizeConfig.setLine( super.service("Line").get( lineId ));
			sizeConfig.setProductCategory( super.service("ProductCategory").get( productCategoryId ) );
			sizeConfig.setHeight( height );
			sizeConfig.setWidth( width );

			var newId = super.service("SizeConfig").create( sizeConfig );
		}
		var result = super.getResult();
		event.setValue( "result", result );
	}

}
