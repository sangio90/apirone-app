component extends="com.apirone.core.controller.AbsController" {

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var modelConfigId      = StructKeyExists( json, "modelConfigId" ) && Len( json.modelConfigId ) ? json.modelConfigId : "";
		var modelId            = Len( json.modelId ) ? json.modelId : "";
		var lineId            = Len( json.lineId ) ? json.lineId : "";
		var productCategoryId = Len( json.productCategoryId ) ? json.productCategoryId : "";
		var height            = Len( json.height ) ? json.height : "";
		var width             = Len( json.width ) ? json.width : "";


		if ( modelConfigId != "" ) {
			// TODO update
			var modelConfig = super.service( "ModelConfig" ).get( modelConfigId );
			if ( IsNull( modelConfig ) ) {
				var message = completeMessage( "modelConfig.notFound" );
				super.getResult().setError( message );
				event.setValue( "result", super.getResult() );
				return;
			}
			modelConfig.setHeight( height );
			modelConfig.setWidth( width );
			var updated = super.service( "ModelConfig" ).update( modelConfig );
		} else {
			// TODO create
			var modelConfig = super.bean( "ModelConfig" );
			modelConfig.setModel( super.service( "Model" ).get( modelId ) );
			modelConfig.setLine( super.service( "Line" ).get( lineId ) );
			modelConfig.setProductCategory( super.service( "ProductCategory" ).get( productCategoryId ) );
			modelConfig.setHeight( height );
			modelConfig.setWidth( width );

			var newId = super.service( "ModelConfig" ).create( modelConfig );
		}
		var result = super.getResult();
		event.setValue( "result", result );
	}

}
