component extends="com.apirone.core.controller.AbsController" {

	function rowConfig( event, rc, prc ){
		param rc.id = "";

		prc.line     = super.fire( "line.get", [ rc.lineId ] );
		prc.model    = super.fire( "model.get", [ rc.modelId ] );
		prc.category = super.fire( "productCategory.get", [ rc.categoryId ] );

		var exists = super.service( "SignageConfig" ).exists( argumentCollection = rc )

		if ( exists ) {
		}

		var fontRows = []

		var fonts = super.fire( "font.list" );

		for ( var item in fonts ) {
			var obj = getDataMapper().convert( item, "Font", true );
			fontRows.add( obj );
		}

		prc.title    = "Configurazione per la linea < #prc.line.getName()#, #prc.model.getName()# >";
		prc.subtitle = "#prc.category.getName()#";


		prc.page[ "fonts" ]        = fontRows;
		prc.page[ "catalogBundle" ] = {
			"id"         = rc.id,
			"lineId"     = rc.lineId,
			"modelId"    = rc.modelId,
			"categoryId" = rc.categoryId
		};

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
