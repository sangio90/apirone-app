/**
 * API della pianificazione ( Gantt ), solo ADM ( permissionRoutes.json.cfm ).
 */
component extends="com.apirone.core.controller.AbsController" {

	/* ======================= Persone ======================= */

	function listPeople( event, rc, prc ){
		var result = super.getResult();
		result.setData( super.service( "Planning" ).listPeople() );
		event.setValue( "result", result );
	}

	function savePerson( event, rc, prc ){
		var result = super.getResult();
		var json   = DeserializeJSON( GetHTTPRequestData().content );

		try {
			super.service( "Planning" ).savePerson( rc.id, json.workTypeId ?: "", json.hours ?: [], json.dayStart ?: "08:00" );
			result.setData( { "message" = "Disponibilità salvata." } );
		} catch ( any e ) {
			// errori di validazione del service ( apirone.planning.* ): messaggio all'utente
			if ( !e.type.startsWith( "apirone.planning." ) ) rethrow;
			fail( result, e.message );
		}

		event.setValue( "result", result );
	}

	/**
	 * Persona senza accesso all'app ( utente disattivato ).
	 */
	function createPerson( event, rc, prc ){
		var result = super.getResult();
		var json   = DeserializeJSON( GetHTTPRequestData().content );

		try {
			var id = super.service( "Planning" ).createPerson( json.name ?: "", json.workTypeId ?: "" );
			result.setData( { "id" = id, "message" = "Persona creata." } );
		} catch ( any e ) {
			// errori di validazione del service ( apirone.planning.* ): messaggio all'utente
			if ( !e.type.startsWith( "apirone.planning." ) ) rethrow;
			fail( result, e.message );
		}

		event.setValue( "result", result );
	}

	/* ======================= Gantt ======================= */

	/**
	 * Dati del Gantt per l'intervallo from / to ( yyyy-mm-dd, inclusi ).
	 */
	function gantt( event, rc, prc ){
		var result = super.getResult();

		if ( !IsDate( rc.from ?: "" ) || !IsDate( rc.to ?: "" ) ) {
			fail( result, "Intervallo di date non valido." );
		} else {
			result.setData( super.service( "Planning" ).ganttData( ParseDateTime( rc.from ), ParseDateTime( rc.to ) ) );
		}

		event.setValue( "result", result );
	}

	/* ======================= Blocchi ======================= */

	/*
		Operazioni sui blocchi del Gantt: la logica ( distribuzione delle ore,
		capacità, giorni lavorabili ) è in PlanningService. Dopo ogni operazione
		il client ricarica i dati del Gantt.
	*/

	function createBlock( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		blockAction( event, function( service ){
			return { "id" = service.createBlock(
				quotationId = json.quotationId,
				userId      = json.userId,
				workTypeId  = json.workTypeId,
				start       = parseDay( json.start ),
				hours       = Val( json.hours ),
				extra       = IsBoolean( json.extra ?: "" ) && json.extra,
				startTime   = json.startTime ?: "",
				note        = json.note ?: "",
				createdBy   = session.user.getId()
			) };
		} );
	}

	function moveBlock( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		blockAction( event, function( service ){
			service.moveBlock( blockId = Val( rc.id ), start = parseDay( json.start ), userId = json.userId ?: "" );
		} );
	}

	function resizeBlock( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		blockAction( event, function( service ){
			service.resizeBlock( blockId = Val( rc.id ), end = parseDay( json.end ) );
		} );
	}

	function splitBlock( event, rc, prc ){
		blockAction( event, function( service ){
			return { "id" = service.splitBlock( blockId = Val( rc.id ) ) };
		} );
	}

	function setBlockDay( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		blockAction( event, function( service ){
			service.setDayHours( blockId = Val( rc.id ), day = parseDay( json.day ), hours = Val( json.hours ) );
		} );
	}

	function setBlockFlags( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		blockAction( event, function( service ){
			service.setBlockFlags(
				blockId       = Val( rc.id ),
				useSaturday   = IsBoolean( json.useSaturday ?: "" ) && json.useSaturday,
				forceHolidays = IsBoolean( json.forceHolidays ?: "" ) && json.forceHolidays
			);
		} );
	}

	/**
	 * Ora di inizio o di fine del blocco ( "HH:MM", passi di 30 minuti ).
	 */
	function setBlockTimes( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		blockAction( event, function( service ){
			service.setBlockTimes( blockId = Val( rc.id ), start = json.start ?: "", end = json.end ?: "" );
		} );
	}

	function setBlockExtra( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		blockAction( event, function( service ){
			service.setBlockExtra( blockId = Val( rc.id ), extra = IsBoolean( json.extra ?: "" ) && json.extra );
		} );
	}

	function setBlockNote( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		blockAction( event, function( service ){
			service.setBlockNote( blockId = Val( rc.id ), note = json.note ?: "" );
		} );
	}

	function deleteBlock( event, rc, prc ){
		blockAction( event, function( service ){
			service.deleteBlock( Val( rc.id ) );
		} );
	}

	/* ======================= Costi orari ======================= */

	function listPersonCosts( event, rc, prc ){
		var result = super.getResult();
		result.setData( super.service( "Planning" ).personCosts( rc.id ) );
		event.setValue( "result", result );
	}

	function savePersonCost( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		blockAction( event, function( service ){
			if ( !IsNumeric( json.hourlyCost ?: "" ) ) {
				Throw( type = "apirone.planning.InvalidCost", message = "Inserisci il costo orario." );
			}
			service.savePersonCost(
				userId     = rc.id,
				validFrom  = parseDay( json.validFrom ?: "" ),
				hourlyCost = json.hourlyCost,
				createdBy  = session.user.getId()
			);
			return { "costs" = service.personCosts( rc.id ) };
		} );
	}

	function deletePersonCost( event, rc, prc ){
		blockAction( event, function( service ){
			service.deletePersonCost( Val( rc.id ) );
		} );
	}

	/* ======================= Statistiche ======================= */

	function stats( event, rc, prc ){
		var result = super.getResult();
		result.setData( super.service( "Planning" ).projectStats() );
		event.setValue( "result", result );
	}

	/* ======================= Chiusure aziendali ======================= */

	function listClosures( event, rc, prc ){
		var result = super.getResult();
		var year   = Val( rc.year ?: Year( Now() ) );

		result.setData( {
			"closures" = super.service( "WorkCalendar" ).listClosures( CreateDate( year, 1, 1 ), CreateDate( year, 12, 31 ) ),
			"holidays" = super.service( "WorkCalendar" ).holidays( year )
		} );
		event.setValue( "result", result );
	}

	function saveClosure( event, rc, prc ){
		var result = super.getResult();
		var json   = DeserializeJSON( GetHTTPRequestData().content );

		if ( !IsDate( json.day ?: "" ) ) {
			fail( result, "Data non valida." );
		} else {
			super.service( "WorkCalendar" ).saveClosure( ParseDateTime( json.day ), json.description ?: "" );
			result.setData( { "message" = "Chiusura salvata." } );
		}

		event.setValue( "result", result );
	}

	function deleteClosure( event, rc, prc ){
		var result = super.getResult();
		super.service( "WorkCalendar" ).deleteClosure( Val( rc.id ) );
		result.setData( { "message" = "Chiusura eliminata." } );
		event.setValue( "result", result );
	}

	/* ======================= Progetti ( ore dei preventivi ) ======================= */

	/**
	 * Preventivi "Confermato da cliente" / "Convertito in ordine" con ore stimate
	 * e pianificate per tipo e stato del progetto ( concluso ).
	 */
	function listProjects( event, rc, prc ){
		var result = super.getResult();
		var projects = super.service( "Planning" ).plannableQuotations().filter( function( quotation ){
			return quotation.plannable;
		} );
		result.setData( projects );
		event.setValue( "result", result );
	}

	function saveProject( event, rc, prc ){
		var result = super.getResult();
		var json   = DeserializeJSON( GetHTTPRequestData().content );

		super.service( "Planning" ).saveProject(
			quotationId = rc.id,
			hours       = json.hours ?: {},
			budgets     = json.budgets ?: {},
			completed   = IsBoolean( json.completed ?: "" ) && json.completed,
			userId      = session.user.getId()
		);

		result.setData( { "message" = "Progetto salvato." } );
		event.setValue( "result", result );
	}

	/*
		private methods
	*/

	/**
	 * Esegue un'operazione sui blocchi: gli errori di validazione del service
	 * ( apirone.planning.* ) tornano all'utente come messaggio.
	 */
	private void function blockAction( required any event, required any action ){
		var result = super.getResult();

		try {
			var data = arguments.action( super.service( "Planning" ) );
			result.setData( IsStruct( data ?: "" ) ? data : {} );
		} catch ( any e ) {
			if ( !e.type.startsWith( "apirone.planning." ) ) rethrow;
			fail( result, e.message );
		}

		arguments.event.setValue( "result", result );
	}

	private Date function parseDay( required String day ){
		if ( !REFind( "^\d{4}-\d{2}-\d{2}$", arguments.day ) ) {
			Throw( type = "apirone.planning.InvalidDate", message = "Data non valida: #arguments.day#" );
		}
		return CreateDate( ListGetAt( arguments.day, 1, "-" ), ListGetAt( arguments.day, 2, "-" ), ListGetAt( arguments.day, 3, "-" ) );
	}

	private void function fail( required any result, required String message ){
		arguments.result.setStatus( "ERROR" );
		arguments.result.setData( { "message" = arguments.message } );
	}

}
