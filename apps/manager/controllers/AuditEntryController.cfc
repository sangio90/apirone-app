component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Audit log";

		var logger = getAuditLogger().getConfig();

		prc.entities = logger.entities;
		prc.actions  = logger.actions;

		prc.jsScripts.add( "app-audit-entry" );

		event.setView( "audit-entry/list" );
	}

}
