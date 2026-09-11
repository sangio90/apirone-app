/**
 * Griglia incisioni di un frutto: lettura e salvataggio dei marker (posizioni ammesse
 * per il simbolo inciso) per attributo radice dell'incisione (IS, II, IL).
 */
component extends="com.apirone.core.controller.AbsController" {

	variables.EDIT_ROLES = [ "ADM", "TCD" ];

	/**
	 * GET /ajax/products/:id/engraving-markers
	 * Attributi radice presenti sul frutto, ognuno con i suoi marker, più la lista dei
	 * codici radice in ordine di priorità (serve al client per risalire l'albero).
	 */
	function list( event, rc, prc ){
		var result  = super.getResult();
		var memy    = super.getMementify();
		var service = super.service( "ProductEngravingMarker" );

		var attributes = service.listEngravingAttributes( productId = rc.id );
		var markers    = service.list( productId = rc.id );

		for ( var attribute in attributes ) {
			attribute[ "markers" ] = [];
			for ( var marker in markers ) {
				if ( marker.getAttributeId() == attribute.id ) {
					attribute.markers.append( memy.convert( marker ) );
				}
			}
		}

		result.setData( {
			"attributes"   = attributes,
			"rootCodes"    = service.rootAttributeCodes(),
			"symbolCodes"  = service.symbolAttributeCodes(),
			"symbolSizeMm" = service.symbolSizeMm(),
			"canEdit"      = canEdit()
		} );
		event.setValue( "result", result );
	}

	/**
	 * POST /ajax/products/:id/engraving-markers/:attributeId
	 * Body: { markers: [ { xPx, yPx, xMm, yMm } ] } nell'ordine voluto; sostituisce la griglia.
	 */
	function save( event, rc, prc ){
		var result = super.getResult();
		var memy   = super.getMementify();
		var json   = DeserializeJSON( GetHTTPRequestData().content );

		if ( !canEdit() ) {
			result.setStatus( "INVALID" );
			result.setData( { "general" = [ { "message" = "Non hai i permessi per modificare la griglia incisioni." } ] } );
			event.setValue( "result", result );
			return;
		}

		var markers = [];
		for ( var row in ( json.markers ?: [] ) ) {
			if ( !IsNumeric( row.xPx ?: "" ) || !IsNumeric( row.yPx ?: "" ) || !IsNumeric( row.xMm ?: "" ) || !IsNumeric( row.yMm ?: "" ) ) {
				result.setStatus( "INVALID" );
				result.setData( { "general" = [ { "message" = "Coordinate del marker non valide." } ] } );
				event.setValue( "result", result );
				return;
			}
			var marker = super.bean( "ProductEngravingMarker" );
			marker.setXPx( row.xPx );
			marker.setYPx( row.yPx );
			marker.setXMm( row.xMm );
			marker.setYMm( row.yMm );
			markers.append( marker );
		}

		var saved = super.service( "ProductEngravingMarker" ).replaceForProductAttribute(
			productId   = rc.id,
			attributeId = rc.attributeId,
			markers     = markers
		);

		result.setData( { "message" = "Griglia incisioni salvata.", "markers" = memy.convertList( saved ) } );
		event.setValue( "result", result );
	}

	private Boolean function canEdit(){
		if ( IsNull( session.user ) || IsNull( session.user.getRole() ) ) {
			return false;
		}
		return ArrayContains( variables.EDIT_ROLES, session.user.getRole().getId() );
	}

}
