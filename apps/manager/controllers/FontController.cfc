component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Font";
		var mm  = super.getMementify();
		var fontFamilies = super.fire( "fontFamily.list" );

		var parsedFontFamilies = []
		parsedFontFamilies.add({ "id": "", "name": "-- Seleziona Font Family"})
		for ( var fontFamily in fontFamilies ) {
			var obj = mm.convert( fontFamily, "list" );
			parsedFontFamilies.add( obj );
		}
		prc.page[ "fontFamilies" ] = parsedFontFamilies

		prc.jsScripts.add( "app-font" );

		event.setView( "font/list" );
	}

}
