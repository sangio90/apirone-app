component extends="com.apirone.core.controller.AbsController" {

	function notifyChange( event, rc, prc ){
		param rc.rawProductId = "_NOT_EXISTS";

		var content = GetHTTPRequestData().content;
		var result  = super.getResult();

		var record = super.service( "RawProduct" ).get( rc.rawProductId );

		if ( !IsJSON( content ) ) {
			result.setStatus( "ERROR" );
			result.setData( {
				"message" = "Content is not JSON",
				"type"    = "ContentNotJSON"
			} );
		} else {
			var json = DeserializeJSON( content );

			if ( !json.keyExists( "action" ) ) {
				result.setStatus( "ERROR" );
				result.setData( {
					"message" = "The key 'action' not exists in JSON",
					"type"    = "ActionKeyNotExists"
				} );
			} else {
				if ( json.action != "update" AND json.action != "delete" ) {
					result.setStatus( "ERROR" );
					result.setData( {
						"message" = "The value [#json.action#] for 'action' key not allowed. Are allowed only: 'update' or 'delete'",
						"type"    = "ActionValueNotAllowed"
					} );
				} else {
					if ( json.keyExists( "date" ) AND Len( json.date ) AND !IsDate( json.date ) ) {
						result.setStatus( "ERROR" );
						result.setData( {
							"message" = "Value [#json.date#] is not a valid date",
							"type"    = "DateValueNotAllowed"
						} );
					} else {
						result.setData( {
							"message" = "Notify registered for [#rc.rawProductId#] product",
							"type"    = "NotifyRegistered"
						} );
					}
				}
			}
		}

		if ( result.getStatus() == "SUCCESS" ) {
			// FIXME: This is a workaround. Remove one product a time. Ex. "MATARMINO" not works.
			// super.getCacheManager().remove( "RawProduct.bean", rc.rawProductId );
			super.getCacheManager().removeAll();

			result.setData( {
				"type"    = "ProductUpdated",
				"message" = "Product [#rc.rawProductId#] updated."
			} );
		}

		cffile(
			action = "APPEND",
			file   = "#ExpandPath( "/../repository/private/logs/verticale-notify.log" )#",
			output = "#Now()# rawProductId:[#rc.rawProductId#]; status:#result.getStatus()#; type:#result.getData().type#; message:#result.getData().message#"
		);

		event.setValue( "result", result );
	}

}
