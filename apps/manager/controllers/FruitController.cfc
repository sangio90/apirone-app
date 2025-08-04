component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title    = "Prodotti base";
		prc.statuses = super.fire( "status.list", [ "PRODUCT" ] );

		prc.page[ "statuses" ]   = prc.statuses;
		prc.page[ "lines" ]      = super.fire( "line.list" );
		prc.page[ "categories" ] = super.fire( "ProductCategory.list", { modeId = "BAS" } );

		prc.jsScripts.add( "app-fruit-list" );

		event.setView( "fruit/list" );
	}

	/*
	function detail( event, rc, prc ){
		prc.fruit = super.fire( "fruit.get", [ rc.id ] );

		prc.title = "Frutto < #prc.fruit.getCode()# >";

		prc.statusList = super.fire( "status.list", [ "line" ] );

		prc.jsScripts.add( "app-component" );
		prc.jsScripts.add( "app-attribute-detail" );
		prc.jsScripts.add( "app-product-attribute-list" );
		prc.jsScripts.add( "app-fruit-detail" );

		prc.page[ "fruitId" ]             = prc.fruit.getId();
		prc.page[ "lines" ]               = super.fire( "line.list" );
		prc.page[ "attributeStatusList" ] = super.fire( "status.list", [ "attribute" ] );

		event.setView( "fruit/detail" );
	}
	*/

}
