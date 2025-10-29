component extends="com.apirone.core.controller.AbsController" {

	function get( event, rc, prc ){
		param rc.id = "";

		var memy = super.getMementify();

		var item    = super.service( "SignageConfigItem" ).get( rc.id );
		var signage = super.service( "SignageConfig" ).get( item.getSignageConfigId() );

		prc.title    = "Configurazione per < #signage.getLine().getName()#, #signage.getModel().getName()#, altezza: #item.getSize().getName()#cm >";
		prc.subtitle = "#signage.getCategory().getName()#";

		prc.fonts = super.fire( "signageConfig.list", { "catalogBundleId" = signage.getCatalogBundle().getId() } );

		prc.jsScripts.add( "app-component-modal" );
		prc.jsScripts.add( "app-signage-config-item" );

		event.setView( "signage/signage-config-item" );
	}

}
