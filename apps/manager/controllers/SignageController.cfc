component extends="com.apirone.core.controller.AbsController" {

	function rowConfig( event, rc, prc ){
		prc.line     = super.fire( "line.get", [ rc.lineId ] );
		prc.model    = super.fire( "model.get", [ rc.modelId ] );
		prc.category = super.fire( "productCategory.get", [ rc.categoryId ] );

		var fontData = []

		var fonts = super.fire( "font.list" );

		for ( var item in fonts ) {
			var obj = getDataMapper().convert( item, "Font", true );
			fontData.add( obj );
		}

		prc.page[ "fonts" ] = fontData;

		prc.title    = "Configurazione dei font per < #prc.line.getName()#, #prc.model.getName()# >";
		prc.subtitle = "#prc.category.getName()#";

		prc.jsScripts.add( "app-signage-config" );

		event.setView( "sign/signage-config" );
	}

	function list( event, rc, prc ){
		prc.title = "Audit log";

		var logger = getAuditLogger().getConfig();

		prc.entities = logger.entities;
		prc.actions  = logger.actions;

		prc.jsScripts.add( "app-audit-entry" );

		event.setView( "audit-entry/list" );
	}

}
