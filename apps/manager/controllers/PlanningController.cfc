/**
 * Pianificazione ( Gantt ): pagine Vue, solo ADM ( permissionRoutes.json.cfm ).
 */
component extends="com.apirone.core.controller.AbsController" {

	/**
	 * Disponibilità persone: tipo di lavoro e ore per giorno della settimana,
	 * chiusure aziendali.
	 */
	function people( event, rc, prc ){
		prc.title = "Disponibilità persone";

		prc.page[ "workTypes" ]    = super.service( "Planning" ).workTypes();
		prc.page[ "defaultHours" ] = super.service( "Planning" ).defaultHours();

		prc.jsFiles.add( "app-planning-people" );

		event.setView( "planning/people" );
	}

	/**
	 * Progetti: ore di attività stimate dei preventivi confermati / convertiti in
	 * ordine e progetto concluso ( esce dal Gantt ).
	 */
	function projects( event, rc, prc ){
		prc.title = "Ore progetti";

		prc.page[ "workTypes" ] = super.service( "Planning" ).workTypes();

		prc.jsFiles.add( "app-planning-projects" );

		event.setView( "planning/projects" );
	}

	/**
	 * Statistiche: costo dei progetti ( ore pianificate × tariffa ) rispetto al budget.
	 */
	function stats( event, rc, prc ){
		prc.title = "Statistiche progetti";

		prc.page[ "workTypes" ] = super.service( "Planning" ).workTypes();

		prc.jsFiles.add( "app-planning-stats" );

		event.setView( "planning/stats" );
	}

	/**
	 * Gantt: persone sui preventivi confermati / convertiti in ordine.
	 */
	function gantt( event, rc, prc ){
		prc.title = "Gantt";

		prc.page[ "workTypes" ] = super.service( "Planning" ).workTypes();

		prc.jsFiles.add( "app-planning-gantt" );
		prc.cssFiles.add( "planning" );

		event.setView( "planning/gantt" );
	}

}
